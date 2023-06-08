<?php

namespace Database\Seeders;

use Illuminate\Support\Str;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;


class MemberSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        db::table('member')->insert([
        'name'=>Str::random(5),
        'email'=>Str::random(10).'@gmail.com',
        'address'=>Str::random(10)
        ]);

    }
}
