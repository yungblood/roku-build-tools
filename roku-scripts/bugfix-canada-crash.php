<?php
    $E['ROKU_CHAN'] = 'dev';
    $E['ROKU_PARMS'] = '';
    $timeout = 30;
    
    $basescript = [
        [ 'expect' => 'DESTRUK',              'action' => 'testNotString',     'parms' => ['EMPTY JSON'] ],
        [ 'expect' => '',                     'action' => 'rokuLaunch',        'parms' => [$E['ROKU_CHAN'], $E['ROKU_PARMS']]],
    ];
    $script = [];
    // Launch the channel 25000 times, looking for an empty json.
    for ($x = 0; $x <= 25000; $x++) {
        $script = array_merge($script, $basescript);
    }
?>