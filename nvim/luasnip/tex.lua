-- LaTeX Snippets
-- TODO:
-- set options for matrix and table snippets (either auto generate or user input)
-- fix integral snippet
-- clean up snippets

--[
-- Setup: LuaSnip imports, define conditions/additional functions for function/dynamic nodes.
--]
local postfix = require("luasnip.extras.postfix").postfix
local line_begin = require("luasnip.extras.conditions.expand").line_begin
local autosnippet = ls.extend_decorator.apply(s, { snippetType = "autosnippet" })

-- condition envs
-- global p! functions from UltiSnips
local function math()
	return vim.api.nvim_eval("vimtex#syntax#in_mathzone()") == 1
end

local function env(name)
	local is_inside = vim.fn["vimtex#env#is_inside"](name)
	return (is_inside[1] > 0 and is_inside[2] > 0)
end

local function tikz()
	return env("tikzpicture")
end

local function bp()
	return env("itemize") or env("enumerate")
end

local function beamer()
	return vim.b.vimtex["documentclass"] == "beamer"
end

-- table of greek symbols
griss = {
	alpha = "alpha",
	beta = "beta",
	delta = "delta",
	gam = "gamma",
	eps = "epsilon",
	mu = "mu",
	lmbd = "lambda",
	sig = "sigma",
}

-- brackets
brackets = {
	a = { "<", ">" },
	b = { "[", "]" },
	c = { "{", "}" },
	m = { "|", "|" },
	p = { "(", ")" },
}

-- dynamic stuff
-- LFG tables and matrices work
local tab = function(args, snip)
	local rows = tonumber(snip.captures[1])
	local cols = tonumber(snip.captures[2])
	local nodes = {}
	local ins_indx = 1
	for j = 1, rows do
		table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
		ins_indx = ins_indx + 1
		for k = 2, cols do
			table.insert(nodes, t(" & "))
			table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
			ins_indx = ins_indx + 1
		end
		table.insert(nodes, t({ "\\\\", "" }))
		if j == 1 then
			table.insert(nodes, t({ "\\midrule", "" }))
		end
	end
	nodes[#nodes] = t("\\\\")
	return sn(nil, nodes)
end

-- yes this is a ripoff
-- thanks L3MON4D3!
local mat = function(args, snip)
	local rows = tonumber(snip.captures[2])
	local cols = tonumber(snip.captures[3])
	local nodes = {}
	local ins_indx = 1
	for j = 1, rows do
		table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
		ins_indx = ins_indx + 1
		for k = 2, cols do
			table.insert(nodes, t(" & "))
			table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
			ins_indx = ins_indx + 1
		end
		table.insert(nodes, t({ "\\\\", "" }))
	end
	-- fix last node.
	nodes[#nodes] = t("\\\\")
	return sn(nil, nodes)
end

-- update for cases
local case = function(args, snip)
	local rows = tonumber(snip.captures[1]) or 2 -- default option 2 for cases
	local cols = 2 -- fix to 2 cols
	local nodes = {}
	local ins_indx = 1
	for j = 1, rows do
		table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
		ins_indx = ins_indx + 1
		for k = 2, cols do
			table.insert(nodes, t(" & "))
			table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
			ins_indx = ins_indx + 1
		end
		table.insert(nodes, t({ "\\\\", "" }))
	end
	-- fix last node.
	nodes[#nodes] = t("\\\\")
	return sn(nil, nodes)
end

-- add table/matrix/case row
local tr = function(args, snip)
	local cols = tonumber(snip.captures[1])
	local nodes = {}
	local ins_indx = 1
	table.insert(nodes, r(ins_indx, "1", i(1)))
	ins_indx = ins_indx + 1
	for k = 2, cols do
		table.insert(nodes, t(" & "))
		table.insert(nodes, r(ins_indx, tostring(k), i(1)))
		ins_indx = ins_indx + 1
	end
	table.insert(nodes, t({ "\\\\", "" }))
	-- fix last node.
	nodes[#nodes] = t("\\\\")
	return sn(nil, nodes)
end

-- integral functions
local int1 = function(args, snip)
	local vars = tonumber(snip.captures[1])
	local nodes = {}
	for j = 1, vars do
		table.insert(nodes, t("\\int_{"))
		table.insert(nodes, r(2*j-1, "lb" .. tostring(j), i(1)))
		table.insert(nodes, t("}^{"))
		table.insert(nodes, r(2*j, "ub" .. tostring(j), i(1)))
		table.insert(nodes, t("} "))
	end
	return sn(nil, nodes)
end

local int2 = function(args, snip)
	local vars = tonumber(snip.captures[1])
	local nodes = {}
	for j = 1, vars do
		table.insert(nodes, t(" \\dd "))
		table.insert(nodes, r(j, "var" .. tostring(j), i(1)))
	end
	return sn(nil, nodes)
end

-- visual util to add insert node
-- thanks ejmastnak!
local get_visual = function(args, parent)
	if #parent.snippet.env.SELECT_RAW > 0 then
		return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
	else -- If SELECT_RAW is empty, return a blank insert node
		return sn(nil, i(1))
	end
end

-- TODO: itemize/enumerate
--[[ rec_ls = function() ]]
--[[ 	return sn(nil, { ]]
--[[ 		c(1, { ]]
--[[ 			-- important!! Having the sn(...) as the first choice will cause infinite recursion. ]]
--[[ 			t({""}), ]]
--[[ 			-- The same dynamicNode as in the snippet (also note: self reference). ]]
--[[ 			sn(nil, {t({"", "\t\\item "}), i(1), d(2, rec_ls, {})}), ]]
--[[ 		}), ]]
--[[ 	}); ]]
--[[ end ]]
--[[]]

--[
-- Snippets go here
--]

return {
	--[
	-- Templates: Stuff for lecture notes, homeworks, and draft documents
	--]
	s(
		{ trig = "texdoc", name = "new tex doc", dscr = "Create a general new tex document" },
		fmt(
			[[ 
    \documentclass{article}
    \usepackage{iftex}
    \ifluatex
    \directlua0{
    pdf.setinfo (
        table.concat (
        {
           "/Title (<>)",
           "/Author (Evelyn Koo)",
           "/Subject (<>)",
           "/Keywords (<>)"
        }, " "
        )
    )
    }
    \fi
    \usepackage{graphicx}
    \graphicspath{{figures/}}
    \usepackage[lecture]{random}
    \pagestyle{fancy}
    \fancyhf{}
    \rhead{\textsc{Evelyn Koo}}
    \chead{\textsc{<>}}
    \lhead{<>}
    \cfoot{\thepage}
    \begin{document}
    \title{<>}
    \author{Evelyn Koo}
    \date{<>}
    \maketitle
    \tableofcontents
    \section*{<>}
    \addcontentsline{toc}{section}{<>}
    <>
    \subsection*{Remarks}
    <>
    \end{document}
    ]],
			{ i(3), i(2), i(7), i(1), rep(2), rep(3), i(4), i(5), rep(5), i(6), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "hwtex", name = "texdoc for hw", dscr = "tex template for my homeworks" },
		fmt(
			[[ 
    \documentclass{article}
    \usepackage{iftex}
    \ifluatex
    \directlua0{
    pdf.setinfo (
        table.concat (
        {
           "/Title (<> <>)",
           "/Author (Evelyn Koo)",
           "/Subject (<>)",
           "/Keywords (<>)"
        }, " "
        )
    )
    }
    \fi
    \usepackage{graphicx}
    \graphicspath{{figures/}}
    \usepackage[lecture]{random}
    \pagestyle{fancy}
    \fancyhf{}
    \rhead{\textsc{Evelyn Koo}}
    \chead{\textsc{Homework <>}}
    \lhead{<>}
    \cfoot{\thepage}
    \begin{document}
    \homework[<>]{<>}{<>}
    <>
    \end{document}
    ]],
			{ t("Homework"), i(1), i(2), i(3), rep(1), rep(2), t(os.date("%d-%m-%Y")), rep(2), rep(1), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "texbook", name = "tex book", dscr = "make a new tex book", hidden = true },
		fmt(
			[[
    \documentclass[twoside]{book}
    \usepackage[utf8]{inputenc}
    \usepackage{makeidx}
    \usepackage{tocbibind}
    \usepackage[totoc]{idxlayout} 
    \input{pre/preamble.tex}

    \begin{document}
    <>
    \end{document}
    ]],
			{ i(1) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "draft", name = "draft", dscr = "draft", hidden = true },
		fmt(
			[[ 
    \documentclass{article}
    \usepackage{random}
    \begin{document}
    <>
    \end{document}
    ]],
			{ i(0) },
			{ delimiters = "<>" }
		),
		{ condition = line_begin, show_condition = line_begin }
	),

	-- [
	-- Introductory Stuff: e.g. table of contents, packages, other setup Stuff
	-- think templates but modular
	-- ]
	s(
		{ trig = "pac", name = "add package", dscr = "add package" },
		fmt(
			[[
    \usepackage<>{<>}
    ]],
			{ c(1, { t(""), sn(nil, { t("["), i(1, "options"), t("]") }) }), i(0, "package") },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "atoc", name = "add toc", dscr = "add this to toc line" },
		fmt(
			[[ 
    \addcontentsline{toc}{<>}{<>}
    <>
    ]],
			{ i(1, "section"), i(2, "content"), i(0) },
			{ delimiters = "<>" }
		)
	),

	--[
	-- Semantic Snippets: sections n stuff, mostly stolen from markdown
	--]

	-- sections from LaTeX
	s(
		{ trig = "#", hidden = true, priority = 250 },
		fmt(
			[[
    \section{<>}\label{sec:<>}
    <>]],
			{ i(1), i(2), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "#*", hidden = true, priority = 250 },
		fmt(
			[[
    \section*{<>}\label{sec:<>}
    <>]],
			{ i(1), i(2), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "##", hidden = true, priority = 500 },
		fmt(
			[[
    \subsection{<>}\label{
    <>]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "##*", hidden = true, priority = 500 },
		fmt(
			[[
    \subsection*{<>}
    <>]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "###", hidden = true, priority = 1000 },
		fmt(
			[[ 
    \subsubsection{<>}
    <>]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "###*", hidden = true, priority = 1000 },
		fmt(
			[[ 
    \subsubsection*{<>}
    <>]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		)
	),

	-- custom sections
	s(
		{ trig = "#l", name = "lecture", dscr = "fancy section header - lecture #", hidden = true },
		fmt(
			[[ 
    \lecture[<>]{<>}
    <>]],
			{ t(os.date("%d-%m-%Y")), i(1), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "#ch", name = "chap", dscr = "fancy section header - chapter #", hidden = true },
		fmt(
			[[ 
    \bookchap[<>]{<>}{<>}
    <>]],
			{ t(os.date("%d-%m-%Y")), i(1, "dscr"), i(2, "\\thesection"), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "#f", name = "fancy section", dscr = "fancy section header - vanilla", hidden = true },
		fmt(
			[[ 
    \fancysec[<>]{<>}{<>}
    <>]],
			{ t(os.date("%d-%m-%Y")), i(1, "dscr"), i(2, "title"), i(0) },
			{ delimiters = "<>" }
		)
	),

	-- links images figures
	s(
		{ trig = "!l", name = "link", dscr = "Link reference", hidden = true },
		fmt([[\href{<>}{\color{<>}<>}<>]], { i(1, "link"), i(3, "blue"), i(2, "title"), i(0) }, { delimiters = "<>" })
	),
	s(
		{ trig = "!i", name = "image", dscr = "Image (no caption, no float)" },
		fmt(
			[[ 
    \begin{center}
    \includegraphics[width=<>\textwidth]{<>}
    \end{center}
    <>]],
			{ i(1, "0.5"), i(2), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "!f", name = "figure", dscr = "Float Figure" },
		fmt(
			[[ 
    \begin{figure}[<>] 
    <>
    \end{figure}]],
			{ i(1, "htb!"), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "gr", name = "figure image", dscr = "float image" },
		fmt(
			[[
    \centering
    \includegraphics[width=<>\textwidth]{<>}\caption{<>}<>]],
			{ i(1, "0.5"), i(2), i(3), i(0) },
			{ delimiters = "<>" }
		)
	),

	-- code highlighting
	s(
		{ trig = "qw", name = "inline code", dscr = "inline code, ft escape" },
		fmt(
			[[\mintinline{<>}<>]],
			{ i(1, "text"), c(2, { sn(nil, { t("{"), i(1), t("}") }), sn(nil, { t("|"), i(1), t("|") }) }) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "qe", name = "code", dscr = "Code with minted." },
		fmt(
			[[ 
    \begin{minted}{<>}
    <>
    \end{minted}
    <>]],
			{ i(1, "python"), i(2), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "mp", name = "minipage", dscr = "create minipage env" }, -- choice node
		fmt(
			[[
    \begin{minipage}{<>\textwidth}
    <>
    \end{minipage}]],
			{ c(1, { t("0.5"), t("0.33"), i(nil) }), i(0) },
			{ delimiters = "<>" }
		)
	),

	-- Book Club

	--[
	-- Text Commands: formatting you'd click a button to do in word for
	--]
	-- quotes
	s(
		{ trig = "sq", name = "single quotes", dscr = "single quotes", hidden = true },
		fmt([[`<>'<>]], { i(1), i(0) }, { delimiters = "<>" })
	),
	s(
		{ trig = "qq", name = "double quotes", dscr = "double quotes", hidden = true },
		fmt([[``<>''<>]], { i(1), i(0) }, { delimiters = "<>" })
	),

	-- text changes
	s(
		{ trig = "bf", name = "bold", dscr = "bold text", hidden = true },
		fmt([[\textbf{<>}<>]], { i(1), i(0) }, { delimiters = "<>" })
	),
	s(
		{ trig = "it", name = "italic", dscr = "italic text", hidden = true },
		fmt([[\textit{<>}<>]], { i(1), i(0) }, { delimiters = "<>" })
	),
	s(
		{ trig = "tu", name = "underline", dscr = "underline text", hidden = true },
		fmt([[\underline{<>}<>]], { i(1), i(0) }, { delimiters = "<>" })
	),
	s(
		{ trig = "sc", name = "small caps", dscr = "small caps text", hidden = true },
		fmt([[\textsc{<>}<>]], { i(1), i(0) }, { delimiters = "<>" })
	),
	s(
		{ trig = "tov", name = "overline", dscr = "overline text" },
		fmt([[\overline{<>}<>]], { i(1), i(0) }, { delimiters = "<>" })
	),

	-- references
	autosnippet(
		{ trig = "alab", name = "labels", dscr = "add a label" },
		fmt(
			[[
    \label{<>:<>}<>
    ]],
			{ i(1), i(2), i(0) },
			{ delimiters = "<>" }
		)
	),
	autosnippet(
		{ trig = "aref", name = "references", dscr = "add a reference" },
		fmt(
			[[
    \ref{<>:<>}<>
    ]],
			{ i(1), i(2), i(0) },
			{ delimiters = "<>" }
		)
	),

	--[
	-- Environments
	--]
	-- generic
	s(
		{ trig = "beg", name = "begin env", dscr = "begin/end environment" },
		fmt(
			[[
    \begin{<>}
    <>
    \end{<>}]],
			{ i(1), i(0), rep(1) },
			{ delimiters = "<>" }
		)
	),

	-- Bullet Points
	s(
		{ trig = "-i", name = "itemize", dscr = "bullet points (itemize)" },
		fmt(
			[[ 
    \begin{itemize}<>
    \item <>
    \end{itemize}]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "-e", name = "enumerate", dscr = "numbered list (enumerate)" },
		fmt(
			[[ 
    \begin{enumerate}<>
    \item <>
    \end{enumerate}]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		)
	),
	-- label n stuff
	autosnippet(
		{ trig = "-l", name = "add label", dscr = "add labeling" },
		fmt(
			[[
    [label=<>]
    ]],
			{ i(1) },
			{ delimiters = "<>" }
		),
		{ condition = bp, show_condition = bp }
	),
	-- generate new bullet points
	autosnippet(
		{ trig = "--", hidden = true },
		{ t("\\item") },
		{ condition = bp * line_begin, show_condition = bp * line_begin }
	),
	autosnippet(
		{ trig = "!-", name = "bp custom", dscr = "bullet point" },
		fmt(
			[[ 
    \item [<>]<>
    ]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = bp * line_begin, show_condition = bp * line_begin }
	),

	-- tcolorboxes
	s(
		{ trig = "adef", name = "add definition", dscr = "add definition box" },
		fmt(
			[[ 
    \begin{definition}[<>]{<>
    }
    \end{definition}]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "aex", name = "add example", dscr = "add example box" },
		fmt(
			[[ 
    \begin{example}[<>]{<>
    }
    \end{example}]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "athm", name = "add theorem", dscr = "add theorem box" },
		fmt(
			[[ 
    \begin{theorem}[<>]{<>
    }
    \end{theorem}]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "nb", name = "notebox", dscr = "add notebox idk why this format is diff" },
		fmt(
			[[ 
    \begin{notebox}[<>]
    <>
    \end{notebox}]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		)
	),

	-- tables/matrices
	s(
		{ trig = "tab(%d+)x(%d+)", regTrig = true, name = "test for tabular", dscr = "test", hidden = true },
		fmt(
			[[
    \begin{tabular}{@{}<>@{}}
    \toprule
    <>
    \bottomrule
    \end{tabular}]],
			{ f(function(_, snip)
				return string.rep("c", tonumber(snip.captures[2]))
			end), d(1, tab) },
			{ delimiters = "<>" }
		)
	),
	s(
		{ trig = "([bBpvV])mat(%d+)x(%d+)([ar])", regTrig = true, name = "matrix", dscr = "matrix trigger lets go", hidden = true },
		fmt(
			[[
    \begin{<>}<>
    <>
    \end{<>}]],
			{
				f(function(_, snip)
					return snip.captures[1] .. "matrix"
				end),
				f(function(_, snip)
					if snip.captures[4] == "a" then
						out = string.rep("c", tonumber(snip.captures[3]) - 1)
						return "[" .. out .. "|c]"
					end
					return ""
				end),
				d(1, mat),
				f(function(_, snip)
					return snip.captures[1] .. "matrix"
				end),
			},
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),

	-- etc
	s(
		{ trig = "sol", name = "solution", dscr = "solution box for homework" },
		fmt(
			[[ 
    \begin{solution}
    <>
    \end{solution}]],
			{ i(0) },
			{ delimiters = "<>" }
		)
	),

	--[
	-- Math Snippets - Environments/Setup Commands
	--]

	-- entering math mode
	autosnippet(
		{ trig = "mk", name = "math", dscr = "inline math" },
		fmt([[$<>$<>]], { i(1), i(0) }, { delimiters = "<>" })
	),
	autosnippet(
		{ trig = "dm", name = "math", dscr = "display math" },
		fmt(
			[[ 
    \[ 
    <>
    .\]
    <>]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = line_begin, show_condition = line_begin }
	),
	autosnippet(
		{ trig = "ali", name = "align", dscr = "align math" },
		fmt(
			[[ 
    \begin{align<>}
    <>
    .\end{align<>}
    ]],
			{ i(1, "*"), i(2), rep(1) },
			{ delimiters = "<>" }
		),
		{ condition = line_begin, show_condition = line_begin }
	),
	autosnippet(
		{ trig = "gat", name = "gather", dscr = "gather math" },
		fmt(
			[[ 
    \begin{gather<>}
    <>
    .\end{gather<>}
    ]],
			{ i(1, "*"), i(2), rep(1) },
			{ delimiters = "<>" }
		),
		{ condition = line_begin, show_condition = line_begin }
	),
	autosnippet(
		{ trig = "eqn", name = "equation", dscr = "equation math" },
		fmt(
			[[
    \begin{equation<>}
    <>
    .\end{equation<>}
    ]],
			{ i(1, "*"), i(2), rep(1) },
			{ delimiters = "<>" }
		),
		{ condition = line_begin, show_condition = line_begin }
	),
	autosnippet(
		{ trig = "(%d?)cases", name = "cases", dscr = "cases", regTrig = true, hidden = true },
		fmt(
			[[
    \begin{cases}
    <>
    .\end{cases}
    ]],
			{ d(1, case) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),

	-- text in math
	autosnippet(
		{ trig = "tt", name = "text", dscr = "text in math" },
		fmt(
			[[
    \text{<>}<>
    ]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet(
		{ trig = "sbf", name = "bold math", dscr = "sam bankrupt fraud" },
		fmt(
			[[ 
    \symbf{<>}<>
    ]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet(
		{ trig = "syi", name = "italic math", dscr = "symit" },
		fmt(
			[[ 
    \symit{<>}<>
    ]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	-- fallback for pdftex
	autosnippet(
		{ trig = "mbf", name = "bold math", dscr = "unfortunately cannot use this joke" },
		fmt(
			[[ 
    \mathbf{<>}<>
    ]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet(
		{ trig = "mit", name = "italic math", dscr = "symit" },
		fmt(
			[[ 
    \mathit{<>}<>
    ]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
    autosnippet("udd", {t('\\underline')},
    { condition=math, show_condition=math }),

	-- delimiters
	s(
		{ trig = "lr", name = "left right", dscr = "left right" },
		fmt([[\left(<>\right)<>]], { i(1), i(0) }, { delimiters = "<>" }),
		{ condition = math }
	),
	autosnippet(
		{ trig = "lr(%a)", name = "left right", dscr = "left right delimiters", regTrig = true, hidden = true },
		fmt(
			[[
    \left<><>right<><>
    ]],
			{
				f(function(_, snip)
					cap = snip.captures[1]
					if brackets[cap] == nil then
						cap = "p"
					end -- set default to parentheses
					return brackets[cap][1]
				end),
				i(1),
				f(function(_, snip)
					cap = snip.captures[1]
					if brackets[cap] == nil then
						cap = "p"
					end
					return brackets[cap][2]
				end),
				i(0),
			},
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	s(
		{ trig = "lrv", name = "left right", dscr = "left right" }, -- TODO: update visual mode
		fmt(
			[[\left(<>\right)<>]],
			{
				f(function(args, snip)
					local res, env = {}, snip.env
					for _, val in ipairs(env.LS_SELECT_RAW) do
						table.insert(res, val)
					end
					return res
				end, {}),
				i(0),
			},
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	s(
		{ trig = "floor", name = "math floor", dscr = "math floor" },
		fmt([[\floor{<>}<>]], { i(1), i(0) }, { delimiters = "<>" }),
		{ condition = math }
	),
	s(
		{ trig = "ceil", name = "math ceiling", dscr = "math ceiling" },
		fmt([[\ceil{<>}<>]], { i(1), i(0) }, { delimiters = "<>" }),
		{ condition = math }
	),

	-- operators, symbols
	autosnippet({ trig = "**", priority = 100 }, { t("\\cdot") }, { condition = math }),
	autosnippet("xx", { t("\\times") }, { condition = math }),
	autosnippet(
		{ trig = "//", name = "fraction", dscr = "fraction (autoexpand)" },
		fmt([[\frac{<>}{<>}<>]], { i(1), i(2), i(0) }, { delimiters = "<>" }),
		{ condition = math }
	),
	autosnippet("==", { t("&="), i(1), t("\\\\") }, { condition = math }),
	autosnippet("!=", { t("\\neq") }, { condition = math }),
	autosnippet(
		{ trig = "conj", name = "conjugate", dscr = "conjugate would have been useful in eecs 126" },
		fmt([[\overline{<>}<>]], { i(1), i(0) }, { delimiters = "<>" }, { condition = math })
	),
	autosnippet("<=", { t("\\leq") }, { condition = math }),
	autosnippet(">=", { t("\\geq") }, { condition = math }),
	autosnippet(">>", { t("\\gg") }, { condition = math }),
	autosnippet("<<", { t("\\ll") }, { condition = math }),
	autosnippet("~~", { t("\\sim") }, { condition = math }),
	autosnippet("~=", { t("\\approx") }, { condition = math, show_condition = math }),
	autosnippet("-=", { t("\\equiv") }, { condition = math, show_condition = math }),
	autosnippet("=~", { t("\\cong") }, { condition = math, show_condition = math }),
	autosnippet(":=", { t("\\definedas") }, { condition = math, show_condition = math }),
	autosnippet(
		{ trig = "abs", name = "abs", dscr = "absolute value" },
		fmt([[\abs{<>}]], { i(1) }, { delimiters = "<>" }),
		{ condition = math, show_condition = math }
	),
	autosnippet("!+", { t("\\oplus") }, { condition = math, show_condition = math }),
	autosnippet("!*", { t("\\otimes") }, { condition = math, show_condition = math }),
	autosnippet({ trig = "!!+", priority = 500 }, { t("\\bigoplus") }, { condition = math, show_condition = math }),
	autosnippet({ trig = "!!*", priority = 500 }, { t("\\bigotimes") }, { condition = math, show_condition = math }),
	autosnippet({ trig = "Oo", priority = 50 }, { t("\\circ") }, { condition = math, show_condition = math }),
    autosnippet("::", {t('\\colon')},
    { condition=math, show_condition=math }),
    autosnippet({ trig='adot', name='dot', dscr='dot above'},
    fmt([[
    \dot{<>}<>
    ]],
    { i(1), i(0) },
    { delimiters='<>' }
    ), { condition=math, show_condition=math }),

	-- sub super scripts
	autosnippet(
		{ trig = "(%a)(%d)", regTrig = true, name = "auto subscript", dscr = "hi" },
		fmt(
			[[<>_<>]],
			{ f(function(_, snip)
				return snip.captures[1]
			end), f(function(_, snip)
				return snip.captures[2]
			end) },
			{ delimiters = "<>" }
		),
		{ condition = math }
	),
    autosnippet(
		{ trig = "(\\%a+)(%d)", regTrig = true, name = "auto subscript", dscr = "hi" },
		fmt(
			[[<>_<>]],
			{ f(function(_, snip)
				return snip.captures[1]
			end), f(function(_, snip)
				return snip.captures[2]
			end) },
			{ delimiters = "<>" }
		),
		{ condition = math }
	),

	autosnippet(
		{ trig = "(%a)_(%d%d)", regTrig = true, name = "auto subscript 2", dscr = "auto subscript for 2+ digits" },
		fmt(
			[[<>_{<>}]],
			{ f(function(_, snip)
				return snip.captures[1]
			end), f(function(_, snip)
				return snip.captures[2]
			end) },
			{ delimiters = "<>" }
		),
		{ condition = math }
	),
	autosnippet(
		{ trig = "__", name = "subscript iii", dscr = "auto subscript for brackets", wordTrig = false },
		fmt(
			[[ 
    _{<>}<>
    ]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet("xnn", { t("x_n") }, { condition = math }),
	autosnippet("xii", { t("x_i") }, { condition = math }),
	autosnippet("xjj", { t("x_j") }, { condition = math }),
	autosnippet("ynn", { t("y_n") }, { condition = math }),
	autosnippet("yii", { t("y_i") }, { condition = math }),
	autosnippet("yjj", { t("y_j") }, { condition = math }),
	autosnippet({ trig = "sr", wordTrig = false }, { t("^2") }, { condition = math }),
	autosnippet({ trig = "cb", wordTrig = false }, { t("^3") }, { condition = math }),
	autosnippet({ trig = "compl", wordTrig = false }, { t("^{c}") }, { condition = math }),
	autosnippet({ trig = "vtr", wordTrig = false }, { t("^{T}") }, { condition = math }),
	autosnippet({ trig = "inv", wordTrig = false }, { t("^{-1}") }, { condition = math }),
	autosnippet(
		{ trig = "td", name = "superscript", dscr = "superscript", wordTrig = false },
		fmt([[^{<>}<>]], { i(1), i(0) }, { delimiters = "<>" }),
		{ condition = math }
	),
	autosnippet(
		{ trig = "sq", name = "square root", dscr = "square root" },
		fmt(
			[[\sqrt<>{<>}<>]],
			{ c(1, { t(""), sn(nil, { t("["), i(1), t("]") }) }), i(2), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math }
	),

	-- (greek) symbols
	-- TODO: add greek symbol thing
	autosnippet("lll", { t("\\ell") }, { condition = math, show_condition = math }),

	-- stuff i need to do calculus
	autosnippet("dd", { t("\\dd") }, { condition = math, show_condition = math }),
	autosnippet("nabl", { t("\\nabla") }, { condition = math, show_condition = math }),
	autosnippet("grad", { t("\\grad") }, { condition = math, show_condition = math }),
	autosnippet(
		{ trig = "lim", name = "lim(sup)", dscr = "lim(sup)" },
		fmt(
			[[ 
    \lim<>_{<> \to <>}<>
    ]],
			{ c(1, { t(""), t("sup") }), i(2, "n"), i(3, "\\infty"), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet(
		{ trig = "part", name = "partial derivative", dscr = "partial derivative" },
		fmt(
			[[ 
    \frac{\ddp <>}{\ddp <>}<>
    ]],
			{ i(1, "V"), i(2, "x"), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet(
		{ trig = "dint", name = "integrals", dscr = "integrals but cooler" },
		fmt(
			[[
    \<>int_{<>}^{<>} <> <> <>
    ]],
			{ c(1, { t(""), t("o") }), i(2, "-\\infty"), i(3, "\\infty"), i(4), t("\\dd"), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet(
		{ trig = "(%d)int", name = "multi integrals", dscr = "please work", regTrig = true, hidden = false },
		fmt(
			[[ 
    <> <> <> <>
    ]],
			{
				c(1, {
					fmta(
						[[
    \<><>nt_{<>}
    ]],
						{
							c(1, { t(""), t("o") }),
							f(function(_, parent, snip)
								inum = tonumber(parent.parent.captures[1]) -- this guy's lineage looking like a research lab's
								res = string.rep("i", inum)
								return res
							end),
							i(2),
						}
					),
					d(nil, int1),
				}),
				i(2),
				d(3, int2),
				i(0),
			},
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet(
		{ trig = "elr", name = "eval left right", dscr = "eval left right" },
		fmt(
			[[ 
    \eval{<>}<>
    ]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet(
		{ trig = "sum", name = "summation", dscr = "summation" },
		fmt(
			[[
    \sum_{<>}^{<>} <>
    ]],
			{ i(1, "i = 0"), i(2, "\\infty"), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet(
		{ trig = "prod", name = "product", dscr = "summation" },
		fmt(
			[[
    \prod_{<>}^{<>} <>
    ]],
			{ i(1, "i = 0"), i(2, "\\infty"), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),

	-- linalg stuff minus matrices
	autosnippet(
		{ trig = "norm", name = "norm", dscr = "norm" },
		fmt(
			[[ 
    \norm{<>}<>
    ]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet(
		{ trig = "iprod", name = "inner product", dscr = "inner product" },
		fmt(
			[[
    \vinner{<>}<>
    ]],
			{ i(1), i(0) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),

	-- discrete maf
	-- reals and number sets
	autosnippet("RR", { t("\\mathbb{R}") }, { condition = math }),
	autosnippet("CC", { t("\\mathbb{C}") }, { condition = math }),
	autosnippet("ZZ", { t("\\mathbb{Z}") }, { condition = math }),
	autosnippet("QQ", { t("\\mathbb{Q}") }, { condition = math }),
	autosnippet("NN", { t("\\mathbb{N}") }, { condition = math, show_condition = math }),
	autosnippet("OO", { t("\\emptyset") }, { condition = math, show_condition = math }),
	autosnippet("pwr", { t("\\powerset") }, { condition = math, show_condition = math }),

	-- quantifiers and cs70 n1 stuff
	autosnippet("AA", { t("\\forall") }, { condition = math }),
	autosnippet("EE", { t("\\exists") }, { condition = math }),
	autosnippet("inn", { t("\\in") }, { condition = math }),
	autosnippet("notin", { t("\\not\\in") }, { condition = math }),
	autosnippet("ooo", { t("\\infty") }, { condition = math }),
	autosnippet("=>", { t("\\implies") }, { condition = math, show_condition = math }),
	autosnippet("=<", { t("\\impliedby") }, { condition = math, show_condition = math }),
	autosnippet("iff", { t("\\iff") }, { condition = math, show_condition = math }),
	autosnippet("||", { t("\\divides") }, { condition = math }),
	autosnippet("!|", { t("\\notdivides") }, { condition = math, show_condition = math }),
	autosnippet({ trig = "->", priority = 250 }, { t("\\to") }, { condition = math }),
	autosnippet({ trig = "-->", priority = 400 }, { t("\\longrightarrow") }, { condition = math }),
	autosnippet({ trig = "<->", priority = 500 }, { t("\\leftrightarrow") }, { condition = math }),
    autosnippet({trig='2>', priority=400}, {t('\\rightrightarrows')},
    { condition=math, show_condition=math }),
	autosnippet("!>", { t("\\mapsto") }, { condition = math }),

	-- sets
	autosnippet(
		{ trig = "set", name = "set", dscr = "set" }, -- overload with set builder notation
		fmt([[\{<>\}<>]], { c(1, { i(nil), sn(nil, { i(1), t("\\mid"), i(2) }) }), i(0) }, { delimiters = "<>" }),
		{ condition = math }
	),
	autosnippet("cc", { t("\\subset") }, { condition = math }),
	autosnippet("cq", { t("\\subseteq") }, { condition = math }),
	autosnippet("\\\\\\", { t("\\setminus") }, { condition = math }),
	autosnippet("Nn", { t("\\cap") }, { condition = math }),
	autosnippet("UU", { t("\\cup") }, { condition = math }),

	-- counting, probability
	autosnippet(
		{ trig = "bnc", name = "binomial", dscr = "binomial (nCR)" },
		fmt([[\binom{<>}{<>}<>]], { i(1), i(2), i(0) }, { delimiters = "<>" }),
		{ condition = math }
	),

	-- etc: utils and stuff
	autosnippet(
		{ trig = "subs", name = "substack", dscr = "if sum two lines" },
		fmt(
			[[
    \substack{<>}
    ]],
			{ i(1) },
			{ delimiters = "<>" }
		),
		{ condition = math, show_condition = math }
	),
	autosnippet(
		{ trig = "([clvd])%.", regTrig = true, name = "dots", dscr = "generate some dots" },
		fmt([[\<>dots]], { f(function(_, snip)
			return snip.captures[1]
		end) }, { delimiters = "<>" }),
		{ condition = math }
	),
	autosnippet("lb", { t("\\\\") }, { condition = math }),
	autosnippet("tcbl", { t("\\tcbline") }),
	autosnippet("ctd", { t("%TODO: "), i(1) }),
	autosnippet("upar", { t("\\uparrow") }, { condition = math, show_condition = math }),
	autosnippet("dnar", { t("\\downarrow") }, { condition = math, show_condition = math }),
	autosnippet("dag", { t("\\dagger") }, { condition = math, show_condition = math }),
},
	{
		-- hats and bars (postfixes)
		postfix(
			{ trig = "bar", snippetType = "autosnippet" },
			{ l("\\bar{" .. l.POSTFIX_MATCH .. "}") },
			{ condition = math }
		),
		postfix("hat", { l("\\hat{" .. l.POSTFIX_MATCH .. "}") }, { condition = math }),
		postfix("..", { l("\\" .. l.POSTFIX_MATCH .. " ") }, { condition = math, show_condition = math }),
		postfix({ trig = ",.", priority = 500 }, { l("\\vec{" .. l.POSTFIX_MATCH .. "}") }, { condition = math }),
		postfix(",,.", { l("\\mat{" .. l.POSTFIX_MATCH .. "}") }, { condition = math }),
		postfix("vr", { l("$" .. l.POSTFIX_MATCH .. "$") }),
		postfix("mbb", { l("\\mathbb{" .. l.POSTFIX_MATCH .. "}") }, { condition = math }),
		postfix("vc", { l("\\mintinline{text}{" .. l.POSTFIX_MATCH .. "}") }),
		postfix("te", { l("\\tilde{" .. l.POSTFIX_MATCH .. "}") }, { condition=math, show_condition=math }),
		-- etc
		-- a living nightmare worth of greek symbols
		-- TODO: replace with regex
		s(
			{ trig = "(alpha|beta|delta)", regTrig = true, name = "griss symbol", dscr = "greek letters hi" },
			fmt([[\<>]], { f(function(_, snip)
				return griss[snip.captures[1]]
			end) }, { delimiters = "<>" }),
			{ condition = math }
		),
		--s("alpha", {t("\\alpha")},
		--{condition = math}),
		--s('beta', {t('\\beta')},
		--{ condition=math }),
		s("delta", { t("\\delta") }, { condition = math }),
		s("gam", { t("\\gamma") }, { condition = math }),
		s("eps", { t("\\epsilon") }, { condition = math }),
		s("veps", { t("\\varepsilon") }, { condition = math }),
		s("lmbd", { t("\\lambda") }, { condition = math }),
		s("mu", { t("\\mu") }, { condition = math }),
		s("theta", { t("\\theta") }, { condition = math, show_condition = math }),
		s("sig", { t("\\sigma") }, { condition = math, show_condition = math }),
		-- stuff i need for m110
	}
