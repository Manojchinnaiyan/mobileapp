package gomain

// Make sure functions start with uppercase for export
// Also add proper comments for gomobile

// SimpleFunction returns a greeting
//
// export SimpleFunction
func SimpleFunction(name string) string {
	return "Hello, " + name + "!"
}

// SumNumbers adds two numbers
//
// export SumNumbers
func SumNumbers(a, b int) int {
	return a + b
}
