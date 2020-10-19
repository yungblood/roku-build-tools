<?php
    $E['ROKU_CHAN'] = 'dev';
    $E['ROKU_PARMS'] = '';
    $timeout = 30;
    
    $script = [
        // Wait for launch to complete, wait 2 seconds.
        [ 'expect' => 'appLaunchComplete',    'action' => 'sleep',             'parms' => [2] ],
        // Choose Settings
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Right',5] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        // Wait for 2 seconds for screen to draw.
        [ 'expect' => '',                     'action' => 'sleep',             'parms' => [2] ],
        // Choose Sign Out
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Right', 2] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Down'] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        // Confirm Sign Out
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Right'] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        // Wait for 2 seconds for screen to draw.
        [ 'expect' => '',                     'action' => 'sleep',             'parms' => [2] ],
        // Press Home to exit app.
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Home'] ],
        // Wait for app to exit.
        [ 'expect' => 'AppExitComplete',      'action' => 'none',              'parms' => [] ],
        [ 'expect' => '________',             'action' => 'none',              'parms' => [] ]
    ];
?>