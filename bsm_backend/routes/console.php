<?php

use Illuminate\Support\Facades\Schedule;

Schedule::command('home-service:auto-cancel')
    ->everyFiveMinutes(); // atau everyMinute()

