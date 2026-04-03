package utilities

import (
	"github.com/xuri/excelize/v2"
)

// ExportToExcel exports data to Excel file
func ExportToExcel(data interface{}, sheetName string) (string, error) {
	// TODO: implement Excel export
	f := excelize.NewFile()
	defer f.Close()

	// Placeholder implementation
	return "", nil
}
