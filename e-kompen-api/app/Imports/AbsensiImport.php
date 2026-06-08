<?php

namespace App\Imports;

use App\Models\Absensi;
use App\Models\Mahasiswa;
use App\Models\Dosen;
use App\Models\MataKuliah;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;

class AbsensiImport implements ToModel, WithHeadingRow
{
    protected $idAdmin;

    public function __construct($idAdmin)
    {
        $this->idAdmin = $idAdmin;
    }

    public function model(array $row)
    {
        // 1. Cari mahasiswa berdasarkan NIM
        $mahasiswa = Mahasiswa::where('nim', $row['nim'])->first();
        if (!$mahasiswa) return null; // skip kalau NIM tidak ditemukan

        // 2. Cari atau buat mata kuliah
        $mataKuliah = MataKuliah::firstOrCreate(
            ['nama_matkul' => $row['nama_matkul']]
        );

        // 3. Cari dosen berdasarkan nama
        $dosen = Dosen::where('nama_lengkap', $row['nama_dosen'])->first();
        if (!$dosen) return null; // skip kalau dosen tidak ditemukan

        // 4. Insert ke tabel absensi
        return new Absensi([
            'id_mahasiswa'   => $mahasiswa->id_mahasiswa,
            'id_mata_kuliah' => $mataKuliah->id_mata_kuliah,
            'id_dosen'       => $dosen->id_dosen,
            'id_admin'       => $this->idAdmin,
            'tanggal'        => $row['tanggal'],
            'status'         => $row['status'],
            'jml_jam'        => $row['jml_jam'],
        ]);
    }
}