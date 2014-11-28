jigSolver
=========

iOS puzzle solving app

Setup
=========

The easiest way to get OpenCV working with this repository is to clone it to your desktop, then open a terminal in the directory of the project file. Then create (touch) a plaintext file called "podfile", open it and populate it with this exact test:

'''
platform :ios, '7.0'

pod 'OpenCV', '~> 2.4.9.1'
'''

Then, run:

'''
pod setup
pod install
'''
Note, you need to have pod installed ahead of time. Once this runs, you should only ever open the project via the workspace it creates.
