Option Explicit
'*********************************************************
' QTPReport CLASS
'*********************************************************
Class QTPReport

	'*********************************************************
	' ATTRIBUTS
	'*********************************************************
	Private arrQTPReport(10) ' Array containing Step Information

	' Array indexes (constants)
	Private QTPREPORT_TESTID
	Private QTPREPORT_TESTDESC
	Private QTPREPORT_TESTSTATUS
	Private QTPREPORT_SUBTESTID
	Private QTPREPORT_SUBTESTDESC
	Private QTPREPORT_SUBTESTSTATUS
	Private QTPREPORT_STEPID
	Private QTPREPORT_STEPDESC
	Private QTPREPORT_OBJECT
	Private QTPREPORT_ACTION
	
	'*********************************************************
	' Initialize/Terminate METHODS
	'*********************************************************
	
	Public Sub Class_Initialize()
		QTPREPORT_TESTID = 1
		QTPREPORT_TESTDESC = 2
		QTPREPORT_TESTSTATUS = 3
		QTPREPORT_SUBTESTID = 4
		QTPREPORT_SUBTESTDESC = 5
		QTPREPORT_SUBTESTSTATUS = 6
		QTPREPORT_STEPID = 7
		QTPREPORT_STEPDESC = 8
		QTPREPORT_OBJECT = 9
		QTPREPORT_ACTION = 10

		arrQTPREPORT(QTPREPORT_TESTID) = ""
		arrQTPREPORT(QTPREPORT_TESTDESC) = ""
		arrQTPREPORT(QTPREPORT_TESTSTATUS) = ""
		Call initializeSubTestInfo()
		Call initializeStepInfo()
	End Sub

	Public Sub Class_Terminate()
		' Nothing
	End Sub

	Private Sub initializeSubTestInfo()
	 	arrQTPREPORT(QTPREPORT_SUBTESTID) = ""
		arrQTPREPORT(QTPREPORT_SUBTESTDESC) = ""
		arrQTPREPORT(QTPREPORT_SUBTESTSTATUS) = ""
	End Sub

	Private Sub initializeStepInfo()
	 	arrQTPREPORT(QTPREPORT_STEPID) = ""
		arrQTPREPORT(QTPREPORT_STEPDESC) = ""
		arrQTPREPORT(QTPREPORT_OBJECT) = ""
		arrQTPREPORT(QTPREPORT_ACTION) = ""
	End Sub

	'*********************************************************
	' PRIVATE METHODS
	'*********************************************************
	
	' Simple Sub which creates the QTP events
	Public Sub addQTPReportEvent(ByVal strQTPStepName, ByVal intReturnCode, ByVal strQTPStepDescription, ByVal strQTPExpected, ByVal strQTPActual, ByVal strScreenshot)

	   Dim varEventStatus
	   Dim strScreenshotImage

		'Convert the return code in QTP event status
		If intReturnCode = 0 Then
			varEventStatus = micPass
		Else
			varEventStatus = micFail
		End If
		'Add the expected result and actual result for a validation
		If strQTPExpected <> "" Then
			strQTPStepDescription = strQTPStepDescription & "     Expected Result: '" & strQTPExpected & "'" & vbCrLf &"     Actual Result: '"& strQTPActual & "'"
		ElseIf strQTPActual <> "" Then 
			strQTPStepDescription = strQTPStepDescription & "     Actual Result: '"& strQTPActual & "'"
		End If
		'Add the QTP event with or without Screenshot 
		strScreenshotImage = ""
		If strScreenshot = "Y" Then
			strScreenshotImage = "ScreenShot.png"
			Desktop.CaptureBitmap strScreenshotImage,True
			Reporter.ReportEvent varEventStatus, strQTPStepName,strQTPStepDescription, 	strScreenshotImage
		Else
			Reporter.ReportEvent varEventStatus, strQTPStepName,strQTPStepDescription
		End If

	End Sub
	
	'*********************************************************
	' PUBLIC METHODS
	'*********************************************************
	Public Sub TestBegin(ByVal strTestId, ByVal strTestDesc)
		arrQTPREPORT(QTPREPORT_TESTID) = strTestId
		arrQTPREPORT(QTPREPORT_TESTDESC) = strTestDesc
		arrQTPREPORT(QTPREPORT_TESTSTATUS) = 0
		Call initializeSubTestInfo()
		Call initializeStepInfo()
		Call addQTPReportEvent ("Test Start: " & arrQTPREPORT(QTPREPORT_TESTID), 0, arrQTPREPORT(QTPREPORT_TESTDESC), "", "", "N")
	End Sub

	Public Sub SubTestBegin(ByVal strSubTestId, ByVal strSubTestDesc)
		arrQTPREPORT(QTPREPORT_SUBTESTID) = strSubTestId
		arrQTPREPORT(QTPREPORT_SUBTESTDESC) = strSubTestDesc
		arrQTPREPORT(QTPREPORT_SUBTESTSTATUS) = 0
		Call initializeStepInfo()
		Call addQTPReportEvent ("SubTest Start: " & arrQTPREPORT(QTPREPORT_SUBTESTID), 0, arrQTPREPORT(QTPREPORT_SUBTESTDESC), "", "", "Y")
	End Sub

	Public Sub StepBegin(ByVal strStepId,ByVal strStepDesc, ByVal strObject, ByVal strAction)
		arrQTPREPORT(QTPREPORT_STEPID) = strStepId
		arrQTPREPORT(QTPREPORT_STEPDESC) = strStepDesc
		arrQTPREPORT(QTPREPORT_OBJECT) = strObject
		arrQTPREPORT(QTPREPORT_ACTION) = strAction
	End Sub

	Public Sub StepEnd(ByVal intStatus,ByVal strExpectedResult,ByVal strActualResult,ByVal strScreenshot)
		Call addQTPReportEvent("Step " & arrQTPREPORT(QTPREPORT_STEPID), intStatus, arrQTPREPORT(QTPREPORT_STEPDESC), strExpectedResult, strActualResult, strScreenshot)
		' Take into account the return code for the subtest status (>0 means an error occurred)
		arrQTPREPORT(QTPREPORT_TESTSTATUS) = arrQTPREPORT(QTPREPORT_TESTSTATUS) + intStatus
		arrQTPREPORT(QTPREPORT_SUBTESTSTATUS) = arrQTPREPORT(QTPREPORT_SUBTESTSTATUS) + intStatus
	End Sub

	Public Sub SubTestEnd()
		Call addQTPReportEvent("SubTest End: " & arrQTPREPORT(QTPREPORT_SUBTESTID), arrQTPREPORT(QTPREPORT_SUBTESTSTATUS), arrQTPREPORT(QTPREPORT_SUBTESTDESC),"", "", "Y")
	End Sub
	
	Public Sub TestEnd()
		Call addQTPReportEvent("Test End: " & arrQTPREPORT(QTPREPORT_TESTID), arrQTPREPORT(QTPREPORT_TESTSTATUS), arrQTPREPORT(QTPREPORT_TESTDESC),"", "", "N")
	End Sub

End Class

'*********************************************************
' CONSTRUCTION FUNCTION
'*********************************************************

Public Function NewQTPReport()
	Set NewQTPReport = New QTPReport
End Function

'*********************************************************
' DATE FORMATING
'*********************************************************

Private Function addLeadingZero(strDateSubPart)
	addLeadingZero = strDateSubPart
	If Len(strDateSubPart) = 1 Then
		addLeadingZero = "0" & strDateSubPart
	End If
End Function

'format date to "yyyymmddhhmmss"
Public Function formatDateToString(dtmDate)
	Dim strMth , strDay, strHr, strMin, strSec

	strMth = addLeadingZero(Month(dtmDate))
	strDay = addLeadingZero(Day(dtmDate))
	strHr = addLeadingZero(Hour(FormatDateTime(dtmDate, vbLongTime)))
	strMin = addLeadingZero(Minute(FormatDateTime(dtmDate, vbLongTime)))
	strSec = addLeadingZero(Second(FormatDateTime(dtmDate, vbLongTime)))

	formatDateToString = Year(dtmDate) & strMth & strDay & strHr & strMin & strSec
End Function
