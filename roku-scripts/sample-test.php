<?php
###################################################################################
# Sample ECP Test + Logging
###################################################################################
#
# Config:
#   $E['ROKU_CHAN'], and $E['ROKU_PARMS'] can be set in test script as done below,
#   or they can be set in the environment.
#
###################################################################################
#
# Script:
#   Each line needs 'expect', 'action', and 'parms'.
#   'expect' searches within the console line.
#   'action' is the function name to call, or 'none'.
#   'parms'  is an array of values to be passed to the function in 'action'.
#
###################################################################################
#
# Notes:
#   Common ECP commands are already defined in roku-test-functions.php.
#   Any other commands that you need should be defined by your script.
#
#   The 2 $script lines in this sample test are required to ensure log closes when
#   user presses "Home".
#
#   $script is processed in the sequence listed.
#   If an expect is never found, script will wait indeffinately, or until user
#   presses ctrl-c.
#
#   If 'action' = 'testString', but the 'parms' value isn't also found in the 
#   same console line, the script will exit as a failed test.
#
#   If 'action' = 'testNotString', and the 'parms' value is also found in the
#   same console line, the script will exit as a failed test.
#
###################################################################################

    $E['ROKU_CHAN'] = 'dev';
    $E['ROKU_PARMS'] = '?contentId=l5ANMH9wM7kxwV1qr4u1xn88XOhYMlZX&mediaType=episode';
    $timeout = 0;
    
    $script = [
        [ 'expect' => 'AppExitComplete', 'action' => 'none', 'parms' => [] ],
        [ 'expect' => '________',        'action' => 'none', 'parms' => [] ]
    ];
?>