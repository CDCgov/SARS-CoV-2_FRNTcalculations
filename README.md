# Simple R code for the Calculation of FRNT50 Values from 96-well Plate Data

**General disclaimer** This repository was created for use by CDC programs to collaborate on public health related projects in support of the [CDC mission](https://www.cdc.gov/about/organization/mission.htm).  GitHub is not hosted by the CDC, but is a third party website used by CDC and its partners to share information and collaborate on software. CDC use of GitHub does not imply an endorsement of any one particular service, product, or enterprise. 

## Access Request, Repo Creation Request

* [CDC GitHub Open Project Request Form](https://forms.office.com/Pages/ResponsePage.aspx?id=aQjnnNtg_USr6NJ2cHf8j44WSiOI6uNOvdWse4I-C2NUNk43NzMwODJTRzA4NFpCUk1RRU83RTFNVi4u) _[Requires a CDC Office365 login, if you do not have a CDC Office365 please ask a friend who does to submit the request on your behalf. If you're looking for access to the CDCEnt private organization, please use the [GitHub Enterprise Cloud Access Request form](https://forms.office.com/Pages/ResponsePage.aspx?id=aQjnnNtg_USr6NJ2cHf8j44WSiOI6uNOvdWse4I-C2NUQjVJVDlKS1c0SlhQSUxLNVBaOEZCNUczVS4u).]_

## Related documents

* [Open Practices](open_practices.md)
* [Rules of Behavior](rules_of_behavior.md)
* [Thanks and Acknowledgements](thanks.md)
* [Disclaimer](DISCLAIMER.md)
* [Contribution Notice](CONTRIBUTING.md)
* [Code of Conduct](code-of-conduct.md)

## System Requirements

The uploaded code should work on any system able to execute R code and install the tidyverse, drc, reshape, and Hmisc packages.  Calls to install these packages are at the head of the R script, which can/should be commented out once required packages are installed.  We have also included the Jupyter notebook code given the popularity of the platform, though setup of Jupyter to run R scripts is considered out side the scope of this documentation.

The existing scripts have been tested on R version 4.1.1 and later, and do not have specific hardware requirements.  Assuming a properly installed R console, installation of the required packages typically takes 3-10 depending on internet connection and processing power.  The script itself requires no other installation and should typically have a fairly rapid run time with datasets of under 200 plates.


## Overview

The following code takes a folder containing a series of CSV files that contain the quantification of foci from an FRNT assay, parses the data in the CSV files, attempts a L3 fit for each paring, and produces a ggplot for each grouping.  To avoid fits that are less appropriate, if a given fit produces a Hill Constant that is less than 0.5 or greater than 2, the code will force a Hill Constant of 1, and then attempt a fit with the other two parameters.

The structure of the CSV should be as described in the [HeaderDetails.txt](./Examples/HeaderDetails.txt) file.  Generally the code is currently setup to handle the data where the first row contains metadata, and the following 8 rows contain the count of foci in a 96-well format.  The code is currently setup to process one virus strain per plate and two serum samples across seven dilutions (6 replicates per sera/antibody per dilution and a no-serum positive control).  This could be modified as needed to cover different plate layouts, but this layout covers our standard FRNT protocols of 6 replicates per pair and dilution.

For convenience the EC50, EC60, EC70, and EC80 are calculated, and (1/EC50) is given for the reported FRNT50 value.  In other words, the value to answer the question, "what dilution ratio of sera will one need to achieve to neutralize 50% of the viral readout for this virus," or how should one dilute a particular sera or antibody sample to achieve a 50% reduction in foci for a particular virus.


## Demo

Given a folder of correct input CSV files (set in a combination of lines 21 and 29) the output should be a single csv file named "final_ec50.csv" written in an output folder set in line 25.  There will also be a single normalized graph produced per "Graph Group" designated in the collection of input CSV files.  

When the provided example plate is run, it should produce three files, as seen in the <a href="https://github.com/CDCgov/SARS-CoV-2_FRNTcalculations/tree/master/Examples/Expected%20Results">Expected Results</a> folder.


## Public Domain Standard Notice
This repository constitutes a work of the United States Government and is not
subject to domestic copyright protection under 17 USC § 105. This repository is in
the public domain within the United States, and copyright and related rights in
the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
All contributions to this repository will be released under the CC0 dedication. By
submitting a pull request you are agreeing to comply with this waiver of
copyright interest.

## License Standard Notice
The repository utilizes code licensed under the terms of the Apache Software
License and therefore is licensed under ASL v2 or later.

This source code in this repository is free: you can redistribute it and/or modify it under
the terms of the Apache Software License version 2, or (at your option) any
later version.

This source code in this repository is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the Apache Software License for more details.

You should have received a copy of the Apache Software License along with this
program. If not, see http://www.apache.org/licenses/LICENSE-2.0.html

The source code forked from other open source projects will inherit its license.

## Privacy Standard Notice
This repository contains only non-sensitive, publicly available data and
information. All material and community participation is covered by the
[Disclaimer](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md)
and [Code of Conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md).
For more information about CDC's privacy policy, please visit [http://www.cdc.gov/other/privacy.html](https://www.cdc.gov/other/privacy.html).

## Contributing Standard Notice
Anyone is encouraged to contribute to the repository by [forking](https://help.github.com/articles/fork-a-repo)
and submitting a pull request. (If you are new to GitHub, you might start with a
[basic tutorial](https://help.github.com/articles/set-up-git).) By contributing
to this project, you grant a world-wide, royalty-free, perpetual, irrevocable,
non-exclusive, transferable license to all users under the terms of the
[Apache Software License v2](http://www.apache.org/licenses/LICENSE-2.0.html) or
later.

All comments, messages, pull requests, and other submissions received through
CDC including this GitHub page may be subject to applicable federal law, including but not limited to the Federal Records Act, and may be archived. Learn more at [http://www.cdc.gov/other/privacy.html](http://www.cdc.gov/other/privacy.html).

## Records Management Standard Notice
This repository is not a source of government records, but is a copy to increase
collaboration and collaborative potential. All government records will be
published through the [CDC web site](http://www.cdc.gov).

## Additional Standard Notices
Please refer to [CDC's Template Repository](https://github.com/CDCgov/template)
for more information about [contributing to this repository](https://github.com/CDCgov/template/blob/master/CONTRIBUTING.md),
[public domain notices and disclaimers](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md),
and [code of conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md).
