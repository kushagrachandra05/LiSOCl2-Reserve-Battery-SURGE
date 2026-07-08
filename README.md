# Simulation and Preliminary Design of Lithium–Thionyl Chloride Reserve Batteries

[![MATLAB](https://img.shields.io/badge/MATLAB-R2024a-orange.svg)]()
[![COMSOL](https://img.shields.io/badge/COMSOL-6.3-blue.svg)]()
[![SolidWorks](https://img.shields.io/badge/SolidWorks-2025-red.svg)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()

Computational investigation into **Lithium–Thionyl Chloride (Li–SOCl₂) reserve batteries** for **short-duration, high-reliability defence applications**, carried out as part of the **Students' Undergraduate Research Graduate Excellence (SURGE) Programme 2026** at the **Indian Institute of Technology Kanpur**.

The project combines **electrochemical modelling**, **multiphysics simulation**, **CAD design**, and **experimental laboratory exposure** to investigate reserve battery behaviour and propose a preliminary computational design framework.

---

## Overview

Lithium–Thionyl Chloride reserve batteries are widely employed in applications requiring:

- Extremely long shelf life (>15 years)
- High specific energy
- Instantaneous activation
- Reliable one-time operation

Typical applications include:

- Artillery fuze batteries
- Missile electronics
- Aerospace systems
- Military communication devices
- Emergency backup power

Unlike conventional batteries, reserve batteries remain electrochemically inactive until the electrolyte is introduced into the electrode assembly immediately prior to use.

---

## Project Objectives

This project investigated five interconnected aspects of reserve battery development:

- Literature review of Li–SOCl₂ electrochemistry and reserve battery architectures
- COMSOL simulation of electrolyte activation using two-phase Level Set modelling
- Electrochemical discharge modelling using COMSOL Battery Design Module
- Development of a MATLAB lumped-parameter discharge model
- Preliminary mechanical design and laboratory exposure to coin-cell fabrication

---

## Methodology

The work was carried out through four complementary stages.

### 1. Literature Review

A comprehensive review of:

- Li–SOCl₂ electrochemistry
- Reserve battery architectures
- Activation mechanisms
- Primary battery modelling

---

### 2. Multiphysics Simulation (COMSOL)

Electrolyte activation was modelled using:

- Laminar two-phase flow
- Level Set interface tracking
- Pressure and velocity field analysis

An attempt was also made to model electrochemical discharge using COMSOL's Battery Design Module.

Although computationally successful, the built-in interfaces were found to be unsuitable for modelling reducible-catholyte Li–SOCl₂ chemistry without significant modification.

---

### 3. MATLAB Electrochemical Model

A reduced-order discharge model was developed using:

- Butler–Volmer kinetics
- Nernst equilibrium potential
- Concentration dynamics
- Temperature-dependent behaviour
- Passivation resistance growth
- State-of-charge estimation

The model successfully reproduced the characteristic discharge plateau observed in Li–SOCl₂ primary cells under different loading conditions.

---

### 4. Mechanical Design

A preliminary reserve battery architecture was developed in SolidWorks, including:

- Housing
- Electrode ring
- Electrolyte ampoule
- Assembly layout

Laboratory exposure to CR2032 coin-cell fabrication was also undertaken to understand practical battery assembly procedures.

---

## Key Results

- Successfully modelled electrolyte activation using COMSOL Level Set Multiphysics.
- Identified limitations of COMSOL Battery Design Module for Li–SOCl₂ electrochemistry.
- Developed a MATLAB discharge model based on electrochemical fundamentals.
- Produced a preliminary CAD design of a reserve battery suitable for artillery fuze applications.
- Gained practical exposure to laboratory coin-cell fabrication and assembly.

---

## Software Used

| Software | Purpose |
|-----------|----------|
| MATLAB | Electrochemical discharge modelling |
| COMSOL Multiphysics 6.3 | Fluid dynamics and electrochemical simulations |
| SolidWorks | CAD modelling |
| LaTeX | Technical report preparation |

---

## Project Outputs

- MATLAB discharge model
- COMSOL multiphysics simulations
- SolidWorks CAD assembly
- SURGE technical report
- Research poster

---

## Limitations

This repository represents a preliminary computational study.

Current limitations include:

- No experimental validation of discharge curves
- Simplified lumped-parameter electrochemical model
- Preliminary CAD design only
- COMSOL electrochemical model limited by Battery Module support for reducible-catholyte chemistry

These limitations are discussed in detail within the report.

---

## Future Work

Potential extensions include:

- Chemistry-specific COMSOL implementation using PDE interfaces
- Experimental validation using fabricated Li–SOCl₂ cells
- Coupled thermal-electrochemical modelling
- Optimisation of reserve battery geometry
- Prototype fabrication and testing

---

## Report

The complete technical report describing the methodology, mathematical models, simulations, and design decisions is available in:

```text
Report/SURGE_Report.pdf
```

---

## Citation

If you use or build upon this work, please cite:

> Kushagra Chandra. *Simulation and Preliminary Design of Lithium–Thionyl Chloride Reserve Batteries for Short-Duration High-Reliability Applications*. Students' Undergraduate Research Graduate Excellence (SURGE), Indian Institute of Technology Kanpur, 2026.

---

## Acknowledgements

This work was carried out under the guidance of **Prof. Abhishek Sarkar** as part of the **Students' Undergraduate Research Graduate Excellence (SURGE) Programme** at the **Indian Institute of Technology Kanpur**.

---

## License

This repository is released under the MIT License.
