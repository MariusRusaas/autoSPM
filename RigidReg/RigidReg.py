import SimpleITK as sitk
import numpy as np
import matlab.engine
import os
import argparse

def RigidReg(refPath, srcPath, other=None, inter=None, reslice=True, verbose=False):
    """
    Main function to run the RigidReg pipeline.

    Parameters:
        refPath (str): Path to the Reference image for registration.
        srcPath (str): Path to the Source image to be registered.
        outputPath (str, optional): Path to save the output image. Defaults to None.
        other (optional): Additional imges to co-register (must be in MNI space).
        inter (optional): Interpolation method for co-registration of additional images in other.

    Returns:
        str: Path to the output image files.
    """
    if verbose: print("################ Running Rigid Registation ################  \n")
    eng = matlab.engine.start_matlab()
    currDir = os.path.dirname(os.path.abspath(__file__))
    eng.addpath(currDir, nargout=0)

    if other is not None:
        others = {othr for othr in other}
        if inter is not None: resliced = eng.RigidReg(refPath, srcPath, reslice, others, np.array(inter))
        else: resliced = eng.RigidReg(refPath, srcPath, reslice, others)
    else: resliced = eng.RigidReg(refPath, srcPath, reslice)

    if verbose: print(f"\n################ Rigid Registration finished! ################  \n")



def main():
    parser = argparse.ArgumentParser(description="Run RigidReg pipeline for brain segmentation and registration.")
    parser.add_argument("--refPath", type=str, required=True, help="Path to the input image file.")
    parser.add_argument("--srcPath", type=str, required=True, help="Path to the CT image file.")
    parser.add_argument("--other", type=str, nargs='*', default=None, help="Additional images to co-register (must be in MNI space).")
    parser.add_argument("--inter", type=int, nargs='*', default=None, help="Interpolation method for co-registration of additional images.")
    parser.add_argument("--verbose", action='store_true', help="Enable verbose output.")
    parser.add_argument("--resliceNot", action='store_false', help="Enable reslicing.")

    args = parser.parse_args()
    
    RigidReg(args.refPath, args.srcPath, 
            other=args.other,
            inter=args.inter, 
            verbose=args.verbose, 
            reslice=args.resliceNot)


if __name__ == "__main__":
    main()
