%% qznu-thesis.cls
%% 泉州师范学院本科毕业论文（设计）LaTeX 文档类
%% 版本: 0.1.2  (2026-11-10)
%% 许可: MIT
%%
%% 设计依据:
%%   1. 《泉州师范学院本科毕业论文（设计）打印格式》（2016 年修订，含封面参考样式）
%%   2. 《泉州师范学院本科毕业论文（设计）工作管理规定》（泉师院教〔2011〕43 号）
%%   3. 泉州师范学院外国语学院《毕业论文（设计）工作实施细则（试行）》（2024）
%%
%% 这是一个依据公开规范编写的第三方模板，不是学校官方模板。
%% 提交前请务必向指导教师和学院教学秘书确认当年最新要求。

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{qznu-thesis}[2026/11/10 v0.1.2 Quanzhou Normal University undergraduate thesis]

% ---------------------------------------------------------------------------
% 选项
% ---------------------------------------------------------------------------
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=qznu,prefix=qznu@}
\DeclareStringOption[1]{scheme}          % 1/2/3/4，对应打印格式中的四种章节编号
\DeclareStringOption[roman]{pagenumber}  % roman（前置部分罗马数字）或 continuous（连续阿拉伯数字）
\DeclareStringOption[center]{chapteralign} % center 或 left
\DeclareStringOption{fontset}            % 传给 ctex：macnew / windows / fandol / ubuntu ...
\ProcessKeyvalOptions*

\ifx\qznu@fontset\@empty
  % macOS 上优先使用较新的系统字体集；其他平台交给 ctex 自动选择。
  \IfFileExists{/System/Library/Fonts/Supplemental/Songti.ttc}
    {\PassOptionsToClass{fontset=macnew}{ctexbook}}
    {}%
\else
  \PassOptionsToClass{fontset=\qznu@fontset}{ctexbook}
\fi

\LoadClass[UTF8,a4paper,zihao=5,openany]{ctexbook}

\RequirePackage{iftex}
\ifXeTeX\else
  \ClassError{qznu-thesis}
    {本模板必须使用 XeLaTeX 编译}
    {请运行：xelatex qznu-thesis.tex，或使用 make。}
\fi

% ---------------------------------------------------------------------------
% 基础宏包
% ---------------------------------------------------------------------------
\RequirePackage{etoolbox}
\RequirePackage{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{titlesec}
\RequirePackage{titletoc}
\RequirePackage{indentfirst}
\RequirePackage{graphicx}
\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{bm}
\RequirePackage{booktabs}
\RequirePackage{array}
\RequirePackage{tabularx}
\RequirePackage{longtable}
\RequirePackage{multirow}
\RequirePackage{makecell}
\RequirePackage{caption}
\RequirePackage{subcaption}
\RequirePackage{enumitem}
\RequirePackage{listings}
\RequirePackage{xcolor}
\RequirePackage{fontspec}
\RequirePackage{hyperref}
\hypersetup{hidelinks,bookmarksnumbered=true,bookmarksopen=true}
\RequirePackage[square,comma,sort&compress]{gbt7714}
% 显式写入一次 \bibstyle，兼容不同 TeX Live 中 gbt7714 的自动写入差异。
\bibliographystyle{gbt7714-numerical}
\AtBeginDocument{\setcitestyle{super,square,comma}}

% ---------------------------------------------------------------------------
% 页面：A4；上下 2 cm；左 2.5 cm（含 0.5 cm 装订线）；右 2 cm
% 页眉距边 1 cm，页脚距边 1 cm，页码居中
% ---------------------------------------------------------------------------
\geometry{
  a4paper,
  top=2cm,
  bottom=2cm,
  left=2.5cm,
  right=2cm,
  headheight=15pt,
  headsep=0.5cm,
  footskip=1cm,
  includehead=false,
  includefoot=false
}

\setlength{\parindent}{2\ccwd}
\setlength{\parskip}{0pt}
\setlength{\emergencystretch}{1.5em}
\renewcommand{\baselinestretch}{1.0}
\clubpenalty=1000
\widowpenalty=1000
\raggedbottom

% ---------------------------------------------------------------------------
% 字体
% ---------------------------------------------------------------------------
\IfFontExistsTF{Times New Roman}
  {\setmainfont{Times New Roman}}
  {\setmainfont{TeX Gyre Termes}}
\IfFontExistsTF{Arial}
  {\setsansfont{Arial}}
  {\setsansfont{TeX Gyre Heros}}
\IfFontExistsTF{Courier New}
  {\setmonofont{Courier New}}
  {\setmonofont{Latin Modern Mono}}

% 中文正文字体由 ctex 的 fontset 决定；没有粗体字库时允许伪粗体。
\xeCJKsetup{AutoFakeBold=2}
% macOS 的 macnew 默认使用 Songti SC Light；这里改用常规字重，更接近宋体正文。
\ifdefstring{\qznu@fontset}{fandol}{%
  \setCJKfamilyfont{zhkai}{FandolKai-Regular.otf}[AutoFakeBold=2]%
}{%
  \IfFontExistsTF{Songti SC}{%
    \setCJKmainfont{Songti SC}[BoldFont=Songti SC Bold]%
    \setCJKfamilyfont{zhsong}{Songti SC}[BoldFont=Songti SC Bold]%
  }{%
    % 楷体通常没有独立粗体；摘要按学校要求需要“楷体加粗”，用伪粗体保证跨平台。
    \IfFontExistsTF{SimKai}{%
      \setCJKfamilyfont{zhkai}{SimKai}[AutoFakeBold=2]%
    }{%
      \IfFontExistsTF{FandolKai-Regular.otf}{%
        \setCJKfamilyfont{zhkai}{FandolKai-Regular.otf}[AutoFakeBold=2]%
      }{}%
    }%
  }%
}

% ---------------------------------------------------------------------------
% 页眉页脚
% ---------------------------------------------------------------------------
\fancypagestyle{qznu}{%
  \fancyhf{}%
  \fancyfoot[C]{\zihao{5}\thepage}%
  \renewcommand{\headrulewidth}{0pt}%
  \renewcommand{\footrulewidth}{0pt}%
}
\fancypagestyle{plain}{%
  \fancyhf{}%
  \fancyfoot[C]{\zihao{5}\thepage}%
  \renewcommand{\headrulewidth}{0pt}%
  \renewcommand{\footrulewidth}{0pt}%
}

% ---------------------------------------------------------------------------
% 中文名称
% ---------------------------------------------------------------------------
\renewcommand{\contentsname}{\texorpdfstring{目\quad 录}{目录}}
\renewcommand{\figurename}{图}
\renewcommand{\tablename}{表}
\renewcommand{\bibname}{参考文献}
\renewcommand{\refname}{参考文献}
\renewcommand{\appendixname}{附录}
\renewcommand{\lstlistingname}{代码}

% ---------------------------------------------------------------------------
% 封面/摘要信息
% ---------------------------------------------------------------------------
\newcommand{\qznu@title}{}
\newcommand{\qznu@subtitle}{}
\newcommand{\qznu@titleen}{}
\newcommand{\qznu@college}{}
\newcommand{\qznu@collegeen}{}
\newcommand{\qznu@major}{}
\newcommand{\qznu@majoren}{}
\newcommand{\qznu@classname}{}
\newcommand{\qznu@studentid}{}
\newcommand{\qznu@author}{}
\newcommand{\qznu@authoren}{}
\newcommand{\qznu@advisor}{}
\newcommand{\qznu@advisoren}{}
\newcommand{\qznu@advisortitle}{}
\newcommand{\qznu@advisortitleen}{}
\newcommand{\qznu@date}{}
\newcommand{\qznu@abstract}{}
\newcommand{\qznu@keywords}{}
\newcommand{\qznu@abstracten}{}
\newcommand{\qznu@keywordsen}{}
\newcommand{\qznu@logo}{figures/qznu-logo-name.png}

\newcommand{\qznutitle}[1]{\gdef\qznu@title{#1}}
\newcommand{\qznusubtitle}[1]{\gdef\qznu@subtitle{#1}}
\newcommand{\qznutitleen}[1]{\gdef\qznu@titleen{#1}}
\newcommand{\qznucollege}[1]{\gdef\qznu@college{#1}}
\newcommand{\qznucollegeen}[1]{\gdef\qznu@collegeen{#1}}
\newcommand{\qznumajor}[1]{\gdef\qznu@major{#1}}
\newcommand{\qznumajoren}[1]{\gdef\qznu@majoren{#1}}
\newcommand{\qznuclass}[1]{\gdef\qznu@classname{#1}}
\newcommand{\qznustudentid}[1]{\gdef\qznu@studentid{#1}}
\newcommand{\qznuauthor}[1]{\gdef\qznu@author{#1}}
\newcommand{\qznuauthoren}[1]{\gdef\qznu@authoren{#1}}
\newcommand{\qznuadvisor}[1]{\gdef\qznu@advisor{#1}}
\newcommand{\qznuadvisoren}[1]{\gdef\qznu@advisoren{#1}}
\newcommand{\qznuadvisortitle}[1]{\gdef\qznu@advisortitle{#1}}
\newcommand{\qznuadvisortitleen}[1]{\gdef\qznu@advisortitleen{#1}}
\newcommand{\qznudate}[1]{\gdef\qznu@date{#1}}
\newcommand{\qznuabstracttext}[1]{\gdef\qznu@abstract{#1}}
\newcommand{\qznukeywords}[1]{\gdef\qznu@keywords{#1}}
\newcommand{\qznuabstractentext}[1]{\gdef\qznu@abstracten{#1}}
\newcommand{\qznukeywordsen}[1]{\gdef\qznu@keywordsen{#1}}
\newcommand{\qznulogo}[1]{\gdef\qznu@logo{#1}}

% ---------------------------------------------------------------------------
% 封面
% ---------------------------------------------------------------------------
\newcommand{\qznu@blank}[2][4.8cm]{%
  \underline{\makebox[#1][c]{\strut #2}}%
}

\newcommand{\makecover}{%
  \hypersetup{%
    pdftitle={\qznu@title},
    pdfauthor={\qznu@author},
    pdfsubject={泉州师范学院本科毕业论文（设计）},
    pdfkeywords={\qznu@keywords},
    bookmarksnumbered=true,
    bookmarksopen=true,
  }%
  \begin{titlepage}
    \centering
    \vspace*{0.45cm}
    \ifdefempty{\qznu@logo}
      {{\heiti\bfseries\fontsize{22}{28}\selectfont
        泉\quad 州\quad 师\quad 范\quad 学\quad 院\par}}
      {\IfFileExists{\qznu@logo}
        {\includegraphics[width=8.4cm]{\qznu@logo}\par}
        {{\heiti\bfseries\fontsize{22}{28}\selectfont
          泉\quad 州\quad 师\quad 范\quad 学\quad 院\par}}}
    \vspace{0.85cm}
    {\heiti\bfseries\fontsize{36}{44}\selectfont
      毕业论文（设计）\par}
    \vspace{1.8cm}
    {\zihao{3} 题\quad 目\par}
    \vspace{0.35cm}
    {\zihao{3}\bfseries \qznu@title\par}
    \vspace{0.18cm}
    \rule{12.5cm}{0.6pt}\par
    \ifdefempty{\qznu@subtitle}{}{%
      \vspace{0.35cm}
      {\zihao{4}\bfseries \qznu@subtitle\par}%
    }
    \vspace{1.25cm}
    {\zihao{3}\kaishu\bfseries
      \renewcommand{\arraystretch}{1.6}%
      \begin{tabular}{@{}r@{\quad}l@{\hspace{1.2em}}r@{\quad}l@{}}
        学\quad 院 & \qznu@blank{\qznu@college} &
        专\quad 业 & \qznu@blank{\qznu@major} \\[0.15em]
        班\quad 级 & \qznu@blank{\qznu@classname} &
        学\quad 号 & \qznu@blank{\qznu@studentid} \\[0.15em]
        学生姓名 & \qznu@blank{\qznu@author} &
        指导教师 & \qznu@blank{\qznu@advisor} \\[0.15em]
        职\quad 称 & \qznu@blank{\qznu@advisortitle} &
        完成日期 & \qznu@blank{\qznu@date} \\
      \end{tabular}\par}
    \vfill
    {\zihao{4}\bfseries 教务处\quad 制\par}
    \vspace*{0.8cm}
  \end{titlepage}
}

% ---------------------------------------------------------------------------
% 中文摘要页（题目 + 作者信息 + 摘要 + 关键词）
% ---------------------------------------------------------------------------
\newenvironment{qznuabstract}
  {\par\begingroup
   \zihao{-5}\kaishu\bfseries
   \setlength{\parindent}{2\ccwd}%
   \noindent\hspace*{2\ccwd}%
   {\heiti\bfseries 【摘\quad 要】}\hspace{0.2em}\ignorespaces}
  {\par\endgroup}

\newcommand{\qznu@printkeywords}{%
  \par\begingroup
  \zihao{-5}\kaishu\bfseries
  \noindent\hspace*{2\ccwd}%
  {\heiti\bfseries 【关键词】}\hspace{0.2em}\qznu@keywords\par
  \endgroup}

\newcommand{\makeabstract}{%
  \clearpage
  \thispagestyle{qznu}%
  \pdfbookmark[0]{摘要}{qznu-abstract}%
  \begin{center}
    {\heiti\bfseries\zihao{-2}\qznu@title\par}
    \ifdefempty{\qznu@subtitle}{}{%
      \vspace{0.2em}
      {\heiti\zihao{4}\qznu@subtitle\par}%
    }
    \vspace{0.8em}
    {\kaishu\bfseries\zihao{-4}
      \qznu@college\quad \qznu@major\quad
      \qznu@studentid（\qznu@author）\par
      指导教师\quad \qznu@advisor\quad \qznu@advisortitle\par}
  \end{center}
  \vspace{0.35\baselineskip}
  \begin{qznuabstract}\qznu@abstract\end{qznuabstract}
  \qznu@printkeywords
}

% ---------------------------------------------------------------------------
% 英文摘要页
% ---------------------------------------------------------------------------
\newenvironment{qznuabstracten}
  {\par\begingroup
   \zihao{5}\rmfamily
   \setlength{\parindent}{2\ccwd}%
   \noindent\hspace*{2\ccwd}%
   \textbf{Abstract.}\hspace{0.3em}\ignorespaces}
  {\par\endgroup}

\newcommand{\makeabstracten}{%
  \clearpage
  \thispagestyle{qznu}%
  \pdfbookmark[0]{Abstract}{qznu-abstract-en}%
  \begin{center}
    {\bfseries\zihao{-2}\qznu@titleen\par}
    \vspace{0.8em}
    {\zihao{-4}
      \qznu@collegeen\par
      \vspace{0.2em}
      \qznu@majoren\quad \qznu@studentid\quad \qznu@authoren\par
      \vspace{0.2em}
      Supervisor\quad \qznu@advisoren\quad \qznu@advisortitleen\par}
  \end{center}
  \vspace{0.35\baselineskip}
  \begin{qznuabstracten}\qznu@abstracten\end{qznuabstracten}
  \par\begingroup
  \zihao{5}\rmfamily
  \noindent\hspace*{2\ccwd}%
  \textbf{Keywords:}\hspace{0.3em}\qznu@keywordsen\par
  \endgroup
}

% ---------------------------------------------------------------------------
% 目录
% ---------------------------------------------------------------------------
\ifdefstring{\qznu@scheme}{1}{\def\qznu@scheme@num{1}}{%
\ifdefstring{\qznu@scheme}{2}{\def\qznu@scheme@num{2}}{%
\ifdefstring{\qznu@scheme}{3}{\def\qznu@scheme@num{3}}{%
\ifdefstring{\qznu@scheme}{4}{\def\qznu@scheme@num{4}}{%
  \ClassError{qznu-thesis}{未知的 scheme 选项：\qznu@scheme}
    {scheme 只能是 1、2、3 或 4。}%
}}}}

\newcommand{\qznu@chapterlabel}{%
  \ifcase\qznu@scheme@num
  \or \thechapter
  \or \thechapter、
  \or 第\chinese{chapter}章
  \or 第\chinese{chapter}章
  \fi}

\newcommand{\qznu@sectionlabel}{%
  \ifcase\qznu@scheme@num
  \or \thesection
  \or （\thesection）
  \or \thesection、
  \or \thesection
  \fi}

\newcommand{\qznu@subsectionlabel}{%
  \ifcase\qznu@scheme@num
  \or \thesubsection
  \or \thesubsection.
  \or （\thesubsection）
  \or \thesubsection
  \fi}

\newcommand{\qznu@subsubsectionlabel}{%
  \ifcase\qznu@scheme@num
  \or \thesubsubsection
  \or （\thesubsubsection）
  \or \thesubsubsection.
  \or \thesubsubsection
  \fi}

\newcommand{\qznu@tocchapterlabel}{%
  \ifx\thecontentslabel\@empty\else\thecontentslabel\fi}

\newcommand{\qznu@tocsectionlabel}{%
  \ifx\thecontentslabel\@empty
  \else
    \ifcase\qznu@scheme@num
    \or \thecontentslabel\hspace{0.4em}%
    \or （\thecontentslabel）\hspace{0.2em}%
    \or \thecontentslabel、\hspace{0.2em}%
    \or \thecontentslabel\hspace{0.4em}%
    \fi
  \fi}

\newcommand{\qznu@tocsubsectionlabel}{%
  \ifx\thecontentslabel\@empty
  \else
    \ifcase\qznu@scheme@num
    \or \thecontentslabel\hspace{0.4em}%
    \or \thecontentslabel.\hspace{0.2em}%
    \or （\thecontentslabel）\hspace{0.2em}%
    \or \thecontentslabel\hspace{0.4em}%
    \fi
  \fi}

\ifnum\qznu@scheme@num=2
  \titlecontents{chapter}[2em]
    {\addvspace{0.35em}\heiti\zihao{5}}
    {\qznu@tocchapterlabel}{}
    {\titlerule*[0.5pc]{.}\contentspage}
\else
  \titlecontents{chapter}[0pt]
    {\addvspace{0.35em}\heiti\zihao{5}}
    {\qznu@tocchapterlabel}{}
    {\titlerule*[0.5pc]{.}\contentspage}
\fi

\titlecontents{section}[3.2em]
  {\zihao{5}\songti}
  {\qznu@tocsectionlabel}{}
  {\titlerule*[0.5pc]{.}\contentspage}

\titlecontents{subsection}[6.4em]
  {\zihao{5}\songti}
  {\qznu@tocsubsectionlabel}{}
  {\titlerule*[0.5pc]{.}\contentspage}

% ---------------------------------------------------------------------------
% 章节格式
% ---------------------------------------------------------------------------
\setcounter{secnumdepth}{3}
\setcounter{tocdepth}{1}

\ifnum\qznu@scheme@num=2
  \titleformat{\chapter}[hang]
    {\heiti\zihao{4}\bfseries}
    {\hspace*{2em}\qznu@chapterlabel}{0.8em}{}
  \titlespacing*{\chapter}{0pt}{1\baselineskip}{0.5\baselineskip}
  \titleformat{\section}[hang]
    {\heiti\zihao{-4}\bfseries}
    {\hspace*{2em}\qznu@sectionlabel}{0.5em}{}
  \titlespacing*{\section}{0pt}{0.5\baselineskip}{0.25\baselineskip}
  \titleformat{\subsection}[hang]
    {\heiti\zihao{5}\bfseries}
    {\hspace*{2em}\qznu@subsectionlabel}{0.5em}{}
  \titlespacing*{\subsection}{0pt}{0.5\baselineskip}{0.25\baselineskip}
  \titleformat{\subsubsection}[hang]
    {\songti\zihao{5}}
    {\hspace*{2em}\qznu@subsubsectionlabel}{0.5em}{}
  \titlespacing*{\subsubsection}{0pt}{0.5\baselineskip}{0.25\baselineskip}
\else
  \ifdefstring{\qznu@chapteralign}{left}{%
    \titleformat{\chapter}[hang]
      {\heiti\zihao{4}\bfseries}
      {\qznu@chapterlabel}{0.8em}{}
  }{%
    \titleformat{\chapter}[block]
      {\heiti\zihao{4}\bfseries\centering}
      {\qznu@chapterlabel}{0.8em}{}
  }
  \titlespacing*{\chapter}{0pt}{1\baselineskip}{0.5\baselineskip}
  \titleformat{\section}[hang]
    {\heiti\zihao{-4}\bfseries}
    {\qznu@sectionlabel}{0.5em}{}
  \titlespacing*{\section}{0pt}{0.5\baselineskip}{0.25\baselineskip}
  \titleformat{\subsection}[hang]
    {\heiti\zihao{5}\bfseries}
    {\qznu@subsectionlabel}{0.5em}{}
  \titlespacing*{\subsection}{0pt}{0.5\baselineskip}{0.25\baselineskip}
  \titleformat{\subsubsection}[hang]
    {\heiti\zihao{5}\bfseries}
    {\qznu@subsubsectionlabel}{0.5em}{}
  \titlespacing*{\subsubsection}{0pt}{0.5\baselineskip}{0.25\baselineskip}
\fi

% 无编号章节（目录、参考文献、致谢、附录）
\titleformat{name=\chapter,numberless}[block]
  {\heiti\zihao{4}\bfseries\centering}{}{0pt}{}
\titlespacing*{name=\chapter,numberless}{0pt}{1\baselineskip}{0.5\baselineskip}

% ---------------------------------------------------------------------------
% 章节编号方案
% ---------------------------------------------------------------------------
\ifcase\qznu@scheme@num
\or
  \renewcommand{\thechapter}{\arabic{chapter}}
  \renewcommand{\thesection}{\thechapter.\arabic{section}}
  \renewcommand{\thesubsection}{\thesection.\arabic{subsection}}
  \renewcommand{\thesubsubsection}{\thesubsection.\arabic{subsubsection}}
\or
  \renewcommand{\thechapter}{\chinese{chapter}}
  \renewcommand{\thesection}{\chinese{section}}
  \renewcommand{\thesubsection}{\arabic{subsection}}
  \renewcommand{\thesubsubsection}{\arabic{subsubsection}}
\or
  \renewcommand{\thechapter}{\arabic{chapter}}
  \renewcommand{\thesection}{\chinese{section}}
  \renewcommand{\thesubsection}{\chinese{subsection}}
  \renewcommand{\thesubsubsection}{\arabic{subsubsection}}
\or
  \renewcommand{\thechapter}{\arabic{chapter}}
  \renewcommand{\thesection}{\thechapter.\arabic{section}}
  \renewcommand{\thesubsection}{\thesection.\arabic{subsection}}
  \renewcommand{\thesubsubsection}{\thesubsection.\arabic{subsubsection}}
\fi

% ctex 默认把“第一章”写入目录；这里统一改为纯编号，由上面的宏补前缀。
\renewcommand{\CTEXthechapter}{\qznu@chapterlabel}

% 图、表、公式按章编号：图 3-1、表 3-1、式 (3-1)
\counterwithin{figure}{chapter}
\counterwithin{table}{chapter}
\counterwithin{equation}{chapter}
\newif\ifqznu@appendix
\newcounter{qznu@appendixnum}
\renewcommand{\thefigure}{%
  \ifqznu@appendix\Alph{qznu@appendixnum}-\arabic{figure}%
  \else\arabic{chapter}-\arabic{figure}\fi}
\renewcommand{\thetable}{%
  \ifqznu@appendix\Alph{qznu@appendixnum}-\arabic{table}%
  \else\arabic{chapter}-\arabic{table}\fi}
\renewcommand{\theequation}{%
  \ifqznu@appendix\Alph{qznu@appendixnum}-\arabic{equation}%
  \else\arabic{chapter}-\arabic{equation}\fi}

% ---------------------------------------------------------------------------
% 图、表、公式、列表
% ---------------------------------------------------------------------------
\captionsetup{
  font=normalsize,
  labelfont=bf,
  labelsep=quad,
  justification=centering,
  skip=4pt
}
\captionsetup[table]{position=top,skip=3pt}
\captionsetup[figure]{position=bottom,skip=3pt}
\renewcommand{\arraystretch}{1.2}
\setlength{\tabcolsep}{4pt}
\newcolumntype{L}[1]{>{\raggedright\arraybackslash}p{#1}}
\newcolumntype{Y}{>{\raggedright\arraybackslash}X}

\lstset{
  basicstyle=\ttfamily\zihao{5},
  columns=fullflexible,
  keepspaces=true,
  frame=single,
  breaklines=true,
  showstringspaces=false,
  extendedchars=true,
  numbers=left,
  numberstyle=\zihao{6},
  numbersep=6pt,
  xleftmargin=1.5em,
  framexleftmargin=1em,
  aboveskip=0.5\baselineskip,
  belowskip=0.5\baselineskip
}

% ---------------------------------------------------------------------------
% 前置/正文分节与页码
% ---------------------------------------------------------------------------
\newcommand{\qznufrontmatter}{%
  \clearpage
  \ifdefstring{\qznu@pagenumber}{roman}
    {\pagenumbering{roman}}
    {\ifdefstring{\qznu@pagenumber}{continuous}{}{\ClassError{qznu-thesis}
      {未知的 pagenumber 选项：\qznu@pagenumber}
      {pagenumber 只能是 roman 或 continuous。}}}%
  \pagestyle{qznu}%
}

\newcommand{\qznumainmatter}{%
  \clearpage
  \ifdefstring{\qznu@pagenumber}{roman}{\pagenumbering{arabic}}{}%
  \pagestyle{qznu}%
}

\newcommand{\qznutableofcontents}{%
  \clearpage
  \thispagestyle{qznu}%
  \pdfbookmark[0]{目录}{qznu-toc}%
  \tableofcontents
}

% ---------------------------------------------------------------------------
% 参考文献、致谢、附录
% ---------------------------------------------------------------------------
\newcommand{\qznubibliography}[1]{%
  \clearpage
  \phantomsection
  \addcontentsline{toc}{chapter}{参考文献}%
  \begingroup
    \titlespacing*{name=\chapter,numberless}{0pt}{2\baselineskip}{0.5\baselineskip}%
    \renewcommand{\bibname}{\heiti\zihao{5}\bfseries 参考文献}%
    \renewcommand{\bibfont}{\zihao{5}}%
    \setlength{\bibsep}{0.15em}%
    \bibliography{#1}%
  \endgroup
}

\newcommand{\qznuspecialchapter}[1]{%
  \clearpage
  \phantomsection
  \chapter*{#1}%
  \addcontentsline{toc}{chapter}{#1}%
}

\newcommand{\qznuappendix}[1]{%
  \stepcounter{qznu@appendixnum}%
  \qznu@appendixtrue
  \setcounter{figure}{0}%
  \setcounter{table}{0}%
  \setcounter{equation}{0}%
  \qznuspecialchapter{#1}}

% ---------------------------------------------------------------------------
% 启动检查与调试信息
% ---------------------------------------------------------------------------
\AtBeginDocument{%
  \setlength{\parindent}{2\ccwd}%
  \linespread{1.0}\selectfont
  \ifdefempty{\qznu@title}
    {\ClassWarningNoLine{qznu-thesis}{未设置 \string\qznutitle，封面题目为空}}{}%
  \ifdefempty{\qznu@author}
    {\ClassWarningNoLine{qznu-thesis}{未设置 \string\qznuauthor，封面姓名为空}}{}%
  \ifdefempty{\qznu@abstract}
    {\ClassWarningNoLine{qznu-thesis}{未设置 \string\qznuabstracttext，中文摘要为空}}{}%
  \typeout{QZNU-GEOMETRY: textwidth=\the\textwidth, textheight=\the\textheight,
    oddsidemargin=\the\oddsidemargin, topmargin=\the\topmargin,
    headheight=\the\headheight, footskip=\the\footskip}%
}

\endinput
