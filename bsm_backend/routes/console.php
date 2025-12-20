<?php

use Illuminate\Support\Facades\Schedule;

Schedule::command('promo:deactivate-expired')
    ->daily();
