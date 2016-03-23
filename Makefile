SHELL=bash

# Folders
out = out
diff_folder_prefix = rohdef-
diff_old = ${diff_folder_prefix}diff-old
diff_result = ${diff_folder_prefix}diff
work_dir = .

# File names
thesis = thesis
thesis_file = ${thesis}.tex
refs_file = refs.bib
diff = diff

BRANCH=master
NON_TEX_FILES = $(filter-out %.tex,$(wildcard *))
TEX_FILES = $(filter %.tex,$(wildcard *))
OLD_TEX_FILES = $(filter ../${diff_old}/%.tex,$(wildcard *))

clean: 
	-rm -rf ${out}

thesis:
	cd ${work_dir}; \
		mkdir -p ${out}; \
		rm ${out}/${refs_file}; \
		ln -s ../${thesis}.pyg ${out}/${thesis}.pyg; \
		echo -e "\e[35m* First pass\e[0m"; \
		pdflatex -shell-escape -interaction=batchmode --output-directory=${out} ${thesis_file} 1>/dev/null; \
		echo -e "\n\e[35m* Running biber\e[0m"; \
		cp ${refs_file} ${out}/; \
		biber --output-directory=${out} ${thesis}; \
		echo -e "\n\e[35m* Second pass\e[0m"; \
		pdflatex -shell-escape -interaction=batchmode --output-directory=${out} ${thesis_file} 1>/dev/null; \
		echo -e "\n\e[35m* Third pass\e[0m"; \
		texfot pdflatex -shell-escape --output-directory=${out} ${thesis_file}

	if [ "${work_dir}" != "." ]; then \
		mv ${work_dir}/${out} .; \
	fi
