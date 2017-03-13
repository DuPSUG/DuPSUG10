. $PSScriptRoot\Helpers\AppVeyorHelpers.ps1

Import-Module $PSScriptRoot\DeepMind.psm1 -Force


Describe "Add-DeepMind" {
    It "Adds <A> and <B> in the cloud and returns <Expected>" -TestCases @(
        @{ A = 1; B = 1; Expected = 2 },
        @{ A = 100; B = 10; Expected = 110 },
        @{ A = -1; B = 1; Expected = 0 }       
    ) {
        param($A, $B, $Expected)
        # -- Arrange

        # -- Act
        $actual = Add-DeepMind -A $A -B $B

        # -- Assert
        $actual | Should Be $Expected
    }
}


Invoke-OnlyDuringRelease {
    Describe "Validate release" {
        It "Module has the same version as tag" {
            Assert-ModuleManifestVersionEqualToTagVersion -Tag $env:APPVEYOR_REPO_TAG_NAME`
		-ManifestPath .\DeepMind.psd1
        }
    }
}