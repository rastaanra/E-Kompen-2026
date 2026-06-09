<?php

namespace App\Imports;

use App\Models\Dosen;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;

class DosenImport implements ToModel, WithHeadingRow
{
    public function model(array $row)
    {
        // Skip baris kalau NIP sudah ada di DB
        $exist = Dosen::where('nip', $row['nip'])->first();
        if ($exist) return null;

        return new Dosen([
            'nip'           => $row['nip'],
            'nama_lengkap'  => $row['nama'],
            'is_kaprodi'    => false,
            'is_registered' => false
        ]);
    }
}