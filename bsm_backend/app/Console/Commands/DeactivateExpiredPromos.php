<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Promo;
use Carbon\Carbon;

class DeactivateExpiredPromos extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:deactivate-expired-promos';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $count = Promo::whereNotNull('end_date')
            ->whereDate('end_date', '<', now())
            ->where('is_active', true)
            ->update(['is_active' => false]);

        $this->info("Expired promos deactivated: {$count}");
    }
}
