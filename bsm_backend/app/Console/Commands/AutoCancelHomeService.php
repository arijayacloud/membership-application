<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\HomeService;

class AutoCancelHomeService extends Command
{
    /**
     * The name and signature of the console command.
     */
    protected $signature = 'home-service:auto-cancel';

    /**
     * The console command description.
     */
    protected $description = 'Auto cancel expired home service';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $count = HomeService::whereIn('status', [
                'pending',
                'approved',
                'on_process'
            ])
            ->whereRaw(
                "TIMESTAMP(schedule_date, schedule_time) < ?",
                [now()]
            )
            ->update([
                'status' => 'canceled'
            ]);

        $this->info("Canceled {$count} expired home services");

        return Command::SUCCESS;
    }
}
