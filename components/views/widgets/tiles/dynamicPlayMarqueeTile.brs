sub init()
    m.top.observeField("focusedChild", "onFocusChanged")

    m.showTitle = m.top.findNode("showTitle")
    m.episodeTitle = m.top.findNode("episodeTitle")
    m.description = m.top.findNode("description")
    
    m.buttonGroup = m.top.findNode("buttonGroup")
    m.ctaButton = m.top.findNode("ctaButton")
    m.about = m.top.findNode("about")

    m.metadata = m.top.findNode("metadata")
    m.progress = m.top.findNode("progress")
    m.progressBar = m.top.findNode("progressBar")
    m.timeIndicator = m.top.findNode("timeIndicator")
    
    m.hero = m.top.findNode("hero")
    m.heroDarken = m.top.findNode("heroDarken")

    m.previewGroup = m.top.findnode("previewGroup")
    'm.vilynxPreview = m.top.findNode("vilynxPreview")
    
    m.vilynxFadeInAnimation = m.top.findNode("vilynxFadeInAnimation")
    m.vilynxFadeOutAnimation = m.top.findNode("vilynxFadeOutAnimation")
    
    m.progressSpacings = [-3, 29, 21, 63]
    m.noProgressSpacings = [-3, 29, 62]
end sub

sub onFocusChanged(nodeEvent)
    if m.top.hasFocus() then
        if m.ctaButton.visible then
            m.ctaButton.setFocus(true)
        else
            m.about.setFocus(true)
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "OK" then
            if m.ctaButton.hasFocus() then
                m.top.buttonSelected = "dynamicPlay"
            else if m.about.hasFocus() then
                m.top.buttonSelected = "showInfo"
            end if
            return true
        else if key = "left" then
            if m.about.hasFocus() and m.ctaButton.visible then
                m.ctaButton.setFocus(true)
                return true
            end if
        else if key = "right" then
            if m.ctaButton.hasFocus() then
                m.about.setFocus(true)
                return true
            end if
        end if
    end if
    return false
end function

sub updateContent()
    if m.show <> invalid then
        m.loadTask = createObject("roSGNode", "loadDynamicPlayEpisodeTask")
        m.loadTask.observeField("episode", "onEpisodeLoaded")
        m.loadTask.showID = m.show.id
        m.loadTask.control = "run"
    end if
end sub

sub onShowChanged()
    if m.show = invalid or not m.show.isSameNode(m.top.show) then
        m.show = m.top.show
        m.showTitle.text = m.show.title
        updateContent()
    end if
end sub

sub onEpisodeLoaded(nodeEvent as object)
    dynamicPlay = nodeEvent.getData()

    m.metadata.itemSpacings = m.noProgressSpacings
    if dynamicPlay <> invalid then
        episode = dynamicPlay.episode
        m.top.episode = episode
        m.top.show.dynamicPlayEpisode = episode

        m.ctaButton.text = uCase(dynamicPlay.title)
        m.ctaButton.visible = true

        m.episodeTitle.text = ((episode.seasonString + " " + episode.episodeString).trim() + " " + episode.title).trim()
        m.description.text = episode.description
     
        if episode.resumePoint <> invalid and episode.resumePoint > 0 then
            percentage = episode.resumePoint / episode.length
            if percentage > 0.5 then
                m.progressBar.maxValue = episode.length
                m.progressBar.value = episode.resumePoint
                if percentage > .97 then
                    m.progressBar.value = m.progressBar.maxValue
                end if
                resumeTime = int((episode.resumePoint / 60) + .5)
                actualTime = (episode.length \ 60)
                timeIndicator = (actualTime - resumeTime).toStr() +"m remaining"
                m.timeIndicator.text = timeIndicator
    
                m.metadata.itemSpacings = m.progressSpacings
                m.metadata.insertChild(m.progress, 3)
            else
                m.metadata.removeChild(m.progress)
            end if
        else
            m.metadata.removeChild(m.progress)
        end if
        m.top.visible = true

        m.loadVilynxTask = createObject("roSGNode", "LoadVilynxVideosTask")
        m.loadVilynxTask.vilynxIDs = [dynamicPlay.episode.id]
        m.loadVilynxTask.observeField("vilynxVideos","onVilynxVideosLoaded")
        m.loadVilynxTask.control = "run"
    else
        ' We don't have content, so hide ourselves
        'm.top.visible = false
        m.hero.uri = getImageUrl(m.show.heroImageUrl, m.hero.width)
        m.hero.visible = true
        m.heroDarken.visible = true

        m.metadata.removeChild(m.progress)
        m.buttonGroup.removeChild(m.ctaButton)
        m.ctaButton.visible = false
    end if
    m.loadTask = invalid
    m.top.contentLoaded = true
end sub

sub startVideoPreview(vilynxThumbnail as string, vilynxUrl as string)
    if m.vilynxPreview = invalid then
        m.vilynxPreview = createObject("roSGNode", "VilynxPreview")
        m.vilynxPreview.width = 1920
        m.vilynxPreview.height = 1080
        m.vilynxPreview.shadeOpacity = .1
        m.previewGroup.appendChild(m.vilynxPreview)
    end if
    m.vilynxPreview.thumbnailUri = vilynxThumbnail
    m.vilynxPreview.heroUri = getImageUrl(m.show.heroImageUrl, m.vilynxPreview.width)
    m.vilynxPreview.videoUri = vilynxUrl
    m.vilynxPreview.control = "play"
    m.vilynxPreview.visible = true
end sub

sub onVilynxVideosLoaded(nodeEvent as object)
    m.loadVilynxTask = invalid
    videos = nodeEvent.getData()

    if m.top.opacity = 1 and videos <> invalid and videos.count() > 0 and videos[0] <> invalid then
        video = videos[0]
        if video <> invalid and m.top.autoplay then
            startVideoPreview(video.vilynxThumbnail, video.vilynxUrlHigh)
        end if
        m.hero.visible = false
    else
        m.hero.uri = getImageUrl(m.show.heroImageUrl, m.hero.width)
        m.hero.visible = true
    end if
end sub

sub onVilynxControlChanged(nodeEvent as object)
    control = nodeEvent.getData()
    if m.vilynxPreview <> invalid then
        m.vilynxPreview.control = control
        if control = "stop" then
            m.previewGroup.removeChild(m.vilynxPreview)
            m.vilynxPreview = invalid
            runGarbageCollector()
        end if
    end if
end sub

