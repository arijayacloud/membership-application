<?php

namespace App\Exports;

use App\Models\Member;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use Maatwebsite\Excel\Concerns\WithEvents;
use Maatwebsite\Excel\Events\AfterSheet;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class MemberExport implements FromCollection, WithHeadings, WithStyles, WithColumnWidths, WithEvents
{
    public function headings(): array
    {
        return [
            'ID',
            'Member Code',
            'Name',
            'Phone',
            'Email',
            'Membership',
            'Status',
            'Expired At',
            'Vehicle Type',
            'Vehicle Brand',
            'Vehicle Model',
            'Vehicle Serial Number',
            'Address',
            'City',
            'Join Date',
        ];
    }

    public function collection()
    {
        return Member::with(['user', 'membershipType'])
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($member) {
                return [
                    $member->id,
                    $member->member_code,
                    $member->user->name ?? '-',
                    $member->user->phone ?? '-',
                    $member->user->email ?? '-',
                    $member->membershipType->name ?? '-',
                    $member->status,
                    optional($member->expired_at)->format('Y-m-d'),
                    $member->vehicle_type,
                    $member->vehicle_brand,
                    $member->vehicle_model,
                    $member->vehicle_serial_number,
                    $member->address,
                    $member->city,
                    optional($member->created_at)->format('Y-m-d'),
                ];
            });
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => [
                'font' => [
                    'bold' => true,
                    'color' => ['rgb' => 'FFFFFF']
                ],
                'fill' => [
                    'fillType' => 'solid',
                    'startColor' => ['rgb' => '1E88E5']
                ],
                'alignment' => [
                    'horizontal' => 'center'
                ]
            ],
        ];
    }

    public function columnWidths(): array
    {
        return [
            'A' => 8,
            'B' => 22,
            'C' => 25,
            'D' => 18,
            'E' => 30,
            'F' => 18,
            'G' => 15,
            'H' => 18,
            'I' => 18,
            'J' => 18,
            'K' => 18,
            'L' => 22,
            'M' => 30,
            'N' => 18,
            'O' => 18,
        ];
    }

    public function registerEvents(): array
    {
        return [
            AfterSheet::class => function (AfterSheet $event) {

                $sheet = $event->sheet->getDelegate();
                $highestRow = $sheet->getHighestRow();
                $highestColumn = $sheet->getHighestColumn();

                // Border semua cell
                $sheet->getStyle("A1:{$highestColumn}{$highestRow}")
                    ->applyFromArray([
                        'borders' => [
                            'allBorders' => [
                                'borderStyle' => 'thin',
                                'color' => ['rgb' => '000000']
                            ]
                        ]
                    ]);

                // Auto filter
                $sheet->setAutoFilter("A1:{$highestColumn}1");

                // Auto height
                $sheet->getDefaultRowDimension()->setRowHeight(-1);

                // Wrap text
                $sheet->getStyle("A1:{$highestColumn}{$highestRow}")
                    ->getAlignment()->setWrapText(true);
            }
        ];
    }
}
