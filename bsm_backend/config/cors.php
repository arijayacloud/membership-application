<?php

return [

    'paths' => ['api/*', 'export/*', 'storage/*', 'media/*', 'sanctum/csrf-cookie'], // ← tambahkan 'export/*'

    'allowed_methods' => ['*'],

    'allowed_origins' => ['*'], // Bisa diganti dengan ['http://localhost:51992'] untuk keamanan

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];
