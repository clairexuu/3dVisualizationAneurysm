import SimpleITK as sitk

img = sitk.ReadImage("data/Anonymous_48_(2)/0 Anonymous_48_Segmentation_1.seg.nrrd")
sitk.WriteImage(img, "data/Anonymous_48_(2)/0 Anonymous_48_Segmentation_1.nii.gz")