# 通用 latexmk 设置；输出目录由 make 或脚本的 -outdir 指定。
$pdf_mode = 5;
$xelatex = 'xelatex -interaction=nonstopmode -file-line-error %O %S';
$bibtex_use = 2;
$max_repeat = 5;

# 清理时一并删除的中间文件
$clean_ext = 'bbl blg fdb_latexmk fls out run.xml synctex.gz toc xdv lof lot';
