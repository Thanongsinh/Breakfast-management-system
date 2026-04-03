package utilities

import (
	"fmt"

	"github.com/xuri/excelize/v2"
)

// ExportToExcel exports data to Excel file
func ExportToExcel(data [][]string, headers []string, sheetName string) (*excelize.File, error) {
	f := excelize.NewFile()

	// Create a new sheet
	index, err := f.NewSheet(sheetName)
	if err != nil {
		return nil, err
	}

	// Set active sheet
	f.SetActiveSheet(index)

	// Create header style
	headerStyle, err := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{
			Bold: true,
			Size: 12,
		},
		Fill: excelize.Fill{
			Type:    "pattern",
			Color:   []string{"#4472C4"},
			Pattern: 1,
		},
		Alignment: &excelize.Alignment{
			Horizontal: "center",
			Vertical:   "center",
		},
	})
	if err != nil {
		return nil, err
	}

	// Write headers
	for i, header := range headers {
		cell := fmt.Sprintf("%c1", 'A'+i)
		f.SetCellValue(sheetName, cell, header)
		f.SetCellStyle(sheetName, cell, cell, headerStyle)
	}

	// Write data
	for rowIdx, row := range data {
		for colIdx, value := range row {
			cell := fmt.Sprintf("%c%d", 'A'+colIdx, rowIdx+2)
			f.SetCellValue(sheetName, cell, value)
		}
	}

	// Auto-fit columns
	for i := range headers {
		col := string(rune('A' + i))
		f.SetColWidth(sheetName, col, col, 15)
	}

	// Delete default Sheet1 if our sheet has a different name
	if sheetName != "Sheet1" {
		f.DeleteSheet("Sheet1")
	}

	return f, nil
}
