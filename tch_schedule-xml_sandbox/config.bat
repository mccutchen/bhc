::================================================::
:: Directory setup				  ::
::================================================::

SET xsl_root=../../
SET py_root=../

SET py_dir_in=py\
SET py_dir_out=..\

SET data_dir_in=data\
SET data_dir_out=..\

SET output_dir_in=output\
SET output_dir_out=..\

SET map_dir_in=mappings\
SET map_dir_out=..\


SET prep_dir_in=xsl\prep\
SET prep_dir_out=..\..\

SET split_dir_in=xsl\split\
SET split_dir_out=..\..\

SET transform_dir_in=xsl\transform\
SET transform_dir_out=..\..\



::================================================::
:: Batch setup					  ::
::================================================::

SET prep_bat=%prep_dir_in%prep
SET split_bat=%split_dir_in%split
SET transform_bat=%transform_dir_in%transform



::================================================::
:: Debug setup					  ::
::================================================::

::Set this to debug in order to keep intermediate files
SET mode=release
::SET mode=debug

