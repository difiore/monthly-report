library(here) # sets working directory
library(tidyverse) # for dplyr, readr, tidyr, tibble, ggplot2, and purrr
library(tcltk2) # for dialog boxes
library(lubridate)
library(readxl) # to read in xlsx files
library(lettercase) # for some string functions
library(stringr) # for some string functions
library(knitr) # for knitting
library(sqldf) # for using SQL
library(magrittr) # for piping
library(officer) # for printing out to word documents
library(flextable) # for tables

fixdate <- function(x, datefield){
	for (i in datefield){
		Y <- year(x[[i]])
		m <- month(x[[i]])
		d <- day(x[[i]])
		x[[i]] <- make_date(year=Y,month=m,day=d)
	}
	return(x)
}

fixtime <- function(x, datefield, timefield, offsetFromGMT, timezone){
	for (i in timefield) {
		Y <- year(x[[datefield]])
		m <- month(x[[datefield]])
		d <- day(x[[datefield]])
		H <- hour(x[[i]]) # local hour
		H <- H - offsetFromGMT # hour GMT
		temp <- as.tibble(cbind(H,d))
		temp <- mutate(temp,newH=ifelse(H>=24,H-24,H),newD=ifelse(H>=24,d+1,d))
		H <- temp$newH
		d <- temp$newD
		M <- minute(x[[i]])
		S <- second(x[[i]])
		x[[i]] <- make_datetime(year=Y,month=m,day=d, hour=H, min=M, sec=S, tz=timezone)
	}
	return(x)
}

obsEntryDialog <- function(x) {
	obslist <- sort(unique(x))
	win <- tktoplevel()
	tktitle(win) <- "Observer(s)"
	label <- tk2label(win, text = "Select name(s)...")
	tkgrid(label, padx=20, pady=c(15, 5))
  listbox <- tk2listbox(win, height=20, width=50, selectmode="multiple")
	tkgrid(listbox, padx=20, pady=c(15, 5))
	for (i in obslist) {
		tkinsert(listbox, "end", i)
	}
	choices <- tclVar()   # tclVar() creates a Tcl variable

	onOK <- function() {
		x <- obslist[as.numeric(tkcurselection(listbox)) + 1]
		tkdestroy(win)
		if (length(x)==0){ x <- ""}
		tclObj(choices) <- x
	}

	onCancel <- function() {
		tkdestroy(win)
		tclObj(choices) <- ""
	}

	OK <- tk2button(win, text = "OK", width = -6, command = onOK)
	Cancel <- tk2button(win, text = "Cancel", width = -6, command = onCancel)
	tkgrid(OK, Cancel, padx = 10, pady = c(15, 15))
	tkwait.variable(choices)
	returnVal <- tclObj(choices)
}

dateRangeEntryDialog <- function(x) {
	datelist <- sort(unique(x))
	#print(datelist)
	#str(datelist)
	#as.Date(as.numeric(datelist[1])/86400,origin = "1970-01-01")
	win <- tktoplevel()
	tktitle(win) <- "Dates"
	label <- tk2label(win, text = "Select start date...")
	tkgrid(label, padx=20, pady=c(15, 5))
	startlist <- tk2listbox(win, height=10, width=50, selectmode="single")
	tkgrid(startlist, padx=20, pady=c(15, 5))
	for (i in datelist) {
		tkinsert(startlist, "end", as.character(as.Date(as.numeric(i)/86400,origin = "1970-01-01")))
	}

	str(datelist)

	label <- tk2label(win, text = "Select end date...")
	tkgrid(label, padx=20, pady=c(15, 5))
	endlist <- tk2listbox(win, height=10, width=50, selectmode="single")
	tkgrid(endlist, padx=20, pady=c(15, 5))
	for (i in datelist) {
		tkinsert(endlist, "end", as.character(as.Date(as.numeric(i)/86400,origin = "1970-01-01")))
	}

	choices <- tclVar()   # tclVar() creates a Tcl variable

	onOK <- function() {
		x1 <- datelist[as.numeric(tkcurselection(startlist)) + 1]
		x2 <- datelist[as.numeric(tkcurselection(endlist)) + 1]
		x <- c(x1,x2)
		tkdestroy(win)
		if (length(x)==0){ x <- ""}
		tclObj(choices) <- x
	}

	onCancel <- function() {
		tkdestroy(win)
		tclObj(choices) <- ""
	}

	OK <- tk2button(win, text = "OK", width = -6, command = onOK)
	Cancel <- tk2button(win, text = "Cancel", width = -6, command = onCancel)
	tkgrid(OK, Cancel, padx = 10, pady = c(15, 15))
	tkwait.variable(choices)
	returnVal <- tclObj(choices)
}
