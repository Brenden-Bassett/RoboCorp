*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.Excel.Files
Library           RPA.FileSystem
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Dialogs
Library           Process
Library           RPA.Robocorp.Vault

*** Variables ***
${GLOBAL_RETRY_AMOUNT}=    3x
${GLOBAL_RETRY_INTERVAL}=    2s
${FILE_PATH_PDF}=    W:/SHARE/Brenden/RoboCorp Training/My-rsb-robot-Level 2/Build A Robot Level II/output/PDF
${FILE_PATH_PNG}=    W:/SHARE/Brenden/RoboCorp Training/My-rsb-robot-Level 2/Build A Robot Level II/output

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Read Secrets
    Open the robot order website
    ${URL_Download}=    Give URL
    Download CSV File    ${URL_Download}
    Create Directory for ZIP Folder
    Fill the form using the data from the csv file

*** Keywords ***
Open the robot order website
    ${Secert_url}=    Get Secret    URL
    Open Available Browser    ${Secert_url}[url_website]

Get Rid of popup
    Click Button    I guess so...

Download CSV File
    [Arguments]    ${URL_Download}
    Download    ${URL_Download}    overwrite=True

Fill the form using the data from the csv file
    ${orders}=    Read table from CSV    orders.csv    header=true
    FOR    ${orders}    IN    @{orders}
        Get Rid of popup
        Fill and Submit One Robot    ${orders}
        Click Preview
        Wait Until Keyword Succeeds    ${GLOBAL_RETRY_AMOUNT}    ${GLOBAL_RETRY_INTERVAL}    Click Order
        ${pdf}=    Export Reciept as PDF    ${orders}
        Open Pdf    ${FILE_PATH_PDF}${/}Robot_Reciept_Order#${orders}[Order number].pdf
        ${screenshot}=    Collect Robot Picture    ${orders}
        Add Watermark Image To Pdf    ${FILE_PATH_PNG}${/}Robot_Pic_Order#${orders}[Order number].png    ${FILE_PATH_PDF}${/}Robot_Reciept_Order#${orders}[Order number].pdf
        Click Order Another Robot
    END
    Create ZIP Package for PDF
    Delete Directory
    Close Browser

Fill and Submit One Robot
    Wait Until Page Does Not Contain Element    I guess so...
    [Arguments]    ${orders}
    Select From List By Value    head    ${orders}[Head]
    Select Radio Button    body    ${orders}[Body]
    Input Text    css:.form-control    ${orders}[Legs]
    Input Text    address    ${orders}[Address]

Click Preview
    Click Button    Preview

Click Order
    Wait Until Element Is Visible    id:robot-preview-image
    Wait Until Element Is Visible    id:order
    Click Button    Order
    Wait Until Element Is Visible    id:receipt

Collect Robot Picture
    [Arguments]    ${orders}
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    robot-preview-image    ${FILE_PATH_PNG}${/}Robot_Pic_Order#${orders}[Order number].png

Export Reciept as PDF
    [Arguments]    ${orders}
    Wait Until Element Is Visible    id:receipt
    ${order_reciept_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_reciept_results_html}    ${FILE_PATH_PDF}${/}Robot_Reciept_Order#${orders}[Order number].pdf

Wait For receipt
    Wait Until Element Is Visible    id:receipt

Click Order Another Robot
    Click Button    id:order-another

Create ZIP Package for PDF
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${FILE_PATH_PDF}
    ...    ${zip_file_name}

Create Directory for ZIP Folder
    Create Directory    ${FILE_PATH_PDF}

Delete Directory
    Remove Directory    ${FILE_PATH_PDF}    True

Give URL
    Add heading    Insert URL for CSV Download
    Add text input    URL    label=CSV FIle
    ${result}=    Run dialog
    [Return]    ${result.URL}

Read Secrets
    ${Secert_url}=    Get Secret    URL
    Log    ${Secert_url}[url_website]

Minimal task
    Log    Done.
