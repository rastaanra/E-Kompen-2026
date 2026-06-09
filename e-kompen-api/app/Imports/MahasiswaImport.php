<?php

namespace App\Imports;

use App\Models\Mahasiswa;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;

class MahasiswaImport implements ToModel, WithHeadingRow
{
    public function model(array $row)
    {
        // Skip baris kalau NIM sudah ada di DB
        $exist = Mahasiswa::where('nim', $row['nim'])->first();
        if ($exist) return null;

        return new Mahasiswa([
            'nim'           => $row['nim'],
            'nama_lengkap'  => $row['nama'],
            'program_studi' => $row['prodi'],
            'is_registered' => false
        ]);
    }
}