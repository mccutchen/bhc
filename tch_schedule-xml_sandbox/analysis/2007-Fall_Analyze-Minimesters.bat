@ECHO Analyzing 2007 Summer I...
@python -m AnalyzeMinimesters ../data/schedule-200-2007S1.xml
@PAUSE

@ECHO Analyzing 2007 Summer II...
@python -m AnalyzeMinimesters ../data/schedule-200-2007S2.xml
@PAUSE

@ECHO Analyzing 2007 Fall...
@python -m AnalyzeMinimesters ../data/schedule-200-2007FA.xml
@PAUSE

@ECHO Analyzing 2008 Spring...
@python -m AnalyzeMinimesters ../data/schedule-200-2008SP.xml
@PAUSE
