<?php
    $E['ROKU_CHAN'] = 'dev';
    $E['ROKU_PARMS'] = '?contentId=l5ANMH9wM7kxwV1qr4u1xn88XOhYMlZX&mediaType=episode';
    $timeout = 30;
    $email = "stonecold@wwf.com";
    $password = "cbs123";
    
    $script = [
        // Wait for launch to complete, wait 2 seconds.
        [ 'expect' => 'AppLaunchComplete',    'action' => 'sleep',             'parms' => [2] ],
        // Select anonymous browse
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Down', 2] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        // Scroll down to live TV
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Down', 20] ],
        [ 'expect' => '',                     'action' => 'sleep',             'parms' => [1] ],
        // Scroll right to ET Live and select.
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Right', 3] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        // On upsell screen, select log in
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Down'] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        // Choose login on Roku.
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        // Wait for user email from device.
        [ 'expect' => '',                     'action' => 'sleep',             'parms' => [6] ],
        // Accept.
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        // Press up to select email
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Up'] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        // Press up to enter keyboard.
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Up'] ],
        // Move to backspace key
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Down', 2] ],
        // Delete 50 chars from email.
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select', 50] ],
        // Enter new email address
        [ 'expect' => '',                     'action' => 'rokuKeyString',     'parms' => [$email] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Enter'] ],
        // Select Password
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        // Enter password
        [ 'expect' => '',                     'action' => 'rokuKeyString',     'parms' => [$password] ],
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Enter'] ],
        // Select Sign In
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Select'] ],
        // Watch for 30 seconds.
        [ 'expect' => '',                     'action' => 'sleep',             'parms' => [30] ],
        // Press Home to exit app.
        [ 'expect' => '',                     'action' => 'rokuKeypress',      'parms' => ['Home'] ],
        // Wait for app to exit.
        [ 'expect' => 'AppExitComplete',      'action' => 'none',              'parms' => [] ],
        [ 'expect' => '________',             'action' => 'none',              'parms' => [] ]
    ];
?>