<?php
    //$E['ROKU_CHAN'] = '31440';

    $script = [
        // Wait for launch to complete, wait 2 seconds.
        [ 'expect' => 'AppLaunchComplete',    'action' => 'sleep',             'parms' => [5] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Down', 9] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        [ 'expect' => '________',             'action' => 'none',              'parms' => [] ]
    ];
?>