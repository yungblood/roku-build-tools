<?php
    //$E['ROKU_CHAN'] = '31440';

    $script = [
        // Wait for launch to complete, wait 2 seconds.
        [ 'expect' => 'AppLaunchInitiate',    'action' => 'sleep',             'parms' => [5] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Down', 5] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Right', 2] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        [ 'expect' => '',                     'action' => 'sleep',             'parms' => [2] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Down', 2] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        [ 'expect' => '',                     'action' => 'sleep',             'parms' => [3] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        [ 'expect' => '',                     'action' => 'sleep',             'parms' => [5] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Back', 2] ],
        [ 'expect' => '________',             'action' => 'none',              'parms' => [] ]
    ];
?>