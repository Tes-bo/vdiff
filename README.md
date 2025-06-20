# vdiff
vdiff is a command line tool for comparing files in two directories, like git diff.

-----

## 🌟 Main Features
	1.	Smart Diff Filtering 🔍
	-	Quickly identifies differing files using diff -rq
	-	Handles both differ (content mismatch) and Only in (file only exists on one side) cases
	-	Skips identical files to significantly boost comparison efficiency

	2.	Accurate Path Handling 🧭
	-	Parses diff output to extract the correct relative file paths
	-	Normalizes directory structures for accurate path matching on both sides

	3.	Enhanced Status Indicators 🖥️
	-	Vim title bar clearly shows the current file being compared
	-	Missing files are displayed as blank buffers, making differences easy to spot

-----


## 🚀 How to Use
	1.	Start the Comparison:

```bash
vdiff directory1 directory2
```


	2.	Controls:
	-	Press `<leader>q` in Vim to quit the entire diff session
	-	Use :qa or close the Vim window to automatically move to the next pair of differing files

	3.	Status View:
	-	Vim title bar shows the current filename
	-	If a file exists only on one side, the other side will show an empty buffer

-----

This version focuses on showing only meaningful differences, skipping identical files to dramatically improve comparison speed. Ideal for quickly spotting and resolving file discrepancies. ⚡🧠

