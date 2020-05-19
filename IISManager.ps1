import-module webadministration
Set-ExecutionPolicy unrestricted
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
$sites= Get-Website | select -expandproperty Name
$Apps=Get-IISAppPool | select -expandproperty Name
#form declaration
$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '600,300'
$Form.text                       = "Form"
$Form.TopMost                    = $false
#compbo box declaration
$buttonCombo                     = New-Object system.Windows.Forms.ComboBox
$buttonCombo.text                = "Type"
$buttonCombo.width               = 200
$buttonCombo.height              = 10
@('WebSite','AppPool') | ForEach-Object {[void] $buttonCombo.Items.Add($_)}
$buttonCombo.location            = New-Object System.Drawing.Point(260,40)
$buttonCombo.Font                = 'Microsoft Sans Serif,10'
#compbo box declaration
$buttonCombo1                     = New-Object system.Windows.Forms.ComboBox
$buttonCombo1.text                = ""
$buttonCombo1.width               = 200
$buttonCombo1.height              = 10
$buttonCombo1.location            = New-Object System.Drawing.Point(260,100)
$buttonCombo1.Font                = 'Microsoft Sans Serif,10'
#button decleration
$submit                          = New-Object system.Windows.Forms.Button
$submit.text                     = "Stop"
$submit.width                    = 60
$submit.height                   = 30
$submit.location                 = New-Object System.Drawing.Point(260,140)
$submit.Font                     = 'Microsoft Sans Serif,10'

$submit1                          = New-Object system.Windows.Forms.Button
$submit1.text                     = "Start"
$submit1.width                    = 60
$submit1.height                   = 30
$submit1.location                 = New-Object System.Drawing.Point(360,140)
$submit1.Font                     = 'Microsoft Sans Serif,10'

#Label to Display Instuctions
$label1 = New-Object system.windows.Forms.Label 
$label1.Text = "Select manage instance"
$label1.AutoSize = $true
$label1.Width = 25
$label1.Height = 10
$label1.location = new-object system.drawing.point(20,40)
$label1.Font = "Microsoft Sans Serif,10"
$label2 = New-Object system.windows.Forms.Label 
$label2.Text = "Select Site/Apppool"
$label2.AutoSize = $true
$label2.Width = 25
$label2.Height = 10
$label2.location = new-object system.drawing.point(20,100)
$label2.Font = "Microsoft Sans Serif,10"

$Form.controls.AddRange(@($submit1,$label1,$label2,$buttonCombo,$submit,$buttonCombo1))

#Logical part

$buttonCombo.Add_SelectedValueChanged({ selectChanged $this $_ })

function selectChanged ($sender,$event) { 
    $global:value= $buttonCombo.Text
    
    if($global:value -eq 'WebSite')
    {
    $buttoncombo1.Items.Clear()
    #[void][system.windows.forms.messagebox]::Show($value)
    $buttonCombo1.Items.AddRange($sites)
    }
    else
    {
    $buttoncombo1.Items.Clear()
    #$buttonCombo1.SelectedIndex.Equals(String.Empty)
    $buttonCombo1.Items.AddRange($Apps)
    }
    }

$buttonCombo1.Add_SelectedValueChanged({ selectChanged1 $this $_ })
function selectChanged1 ($sender,$event) { 
$global:value1=$buttonCombo1.Text
}
$submit.Add_Click({ stopClick $this $_ })
function stopClick ($sender,$event) 
{
  try{
        if($global:value -eq 'WebSite')
        {
            $stats= Get-WebsiteState -Name $global:value1
            $stat= $stats| select -expandproperty Value
            if($stat -eq 'Started')
               {
                    Stop-WebSite -Name $global:value1
                    [void][system.windows.forms.messagebox]::Show($global:value1 + "Website stopped successfully")
                }
             else
                {
              [void][system.windows.forms.messagebox]::Show($global:value1 + "Website Already stopped")
                 }
         }
        else
        {
          $appstat= Get-WebAppPoolState $global:value1 |select -expandproperty Value
          if($appstat -eq 'Started')
            {
            Stop-WebAppPool -Name $global:value1
            [void][system.windows.forms.messagebox]::Show($global:value1 + "Apppool stopped successfully")
            }
            else
            {
              [void][system.windows.forms.messagebox]::Show($global:value1 + "Apppool Already stopped")
            }
           }
       }
catch{

}
}


$submit1.Add_Click({ startClick $this $_ })
function startClick ($sender,$event)
{
    try{
        if($global:value -eq 'WebSite')
          {
            $stats= Get-WebsiteState -Name $global:value1
            $stat= $stats| select -expandproperty Value
            if($stat -eq 'Stopped')
            {
                Start-WebSite -Name $global:value1
                [void][system.windows.forms.messagebox]::Show($global:value1 + "Website started successfully")
             }
             else{[void][system.windows.forms.messagebox]::Show($global:value1 + "Website Already started")
             }
           }
        else{
             $appstat= Get-WebAppPoolState $global:value1 |select -expandproperty Value
            if($appstat -eq 'Stopped')
            {
                Start-WebAppPool -Name $global:value1
                [void][system.windows.forms.messagebox]::Show($global:value1 + "Apppool started successfully")
                }
            else{
            [void][system.windows.forms.messagebox]::Show($global:value1 + "Apppool Already started")
                }
            }
}
catch{

}
}
[void]$Form.ShowDialog()

#License reserd to PrakashN.
