from setuptools import setup

setup(
    name='pipeline',
    version='0.1',
    packages=[''],
    install_requires=['apache-beam[gcp]'],
    setup_requires=['apache-beam[gcp]'],
)