### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ aef2f062-19de-4cbc-b6cf-01d93c767d4a
begin
	using AeroFuse
	using CalculusWithJulia
	using DataFrames
	using Markdown 
	using LinearAlgebra
	using PlutoUI  
	using Plots
	using PrettyTables
	using Xfoil
	using Polynomials.PolyCompat
end

# ╔═╡ 64afbf40-e7aa-11ee-282e-579216dd0e65
md"""
# MECH3620 Aircraft Design Final Project
Group 2:\
CHEUNG Yim Ho Sunny（20918447）\
NG Kow Hei Ryan(20857215)\
POON Chin Ho Jerek(20795792) \
WONG Ka Ho Samuel(20917819) \
WONG Yiu Ting Jeffery(20815554)\
"""

# ╔═╡ a5c3f51f-339d-4039-83d1-8eec15ee3790
TableOfContents(title= "Mech 3620 Group 2")

# ╔═╡ 5c315eca-2a67-4d43-b294-dc2d7996f434
gr( # Change to plotlyjs() for interactivity
	grid = true, 	   # Disable the grid for a e s t h e t i c
	size = (800, 520), # Adjust the dimensions to suit your monitor
	dpi = 300     	   # Higher DPI = higher density
)

# ╔═╡ 1bc89999-2ada-47d7-89a9-4314eb09c1c2
md"
Dear Mr. Seth,

Thank you for choosing us for manufacturing your new private jet. As per the document we received, the requirement that your document listed are as follows:

| **Requirements~of~Proposed~Aircraft** | **Numbers** |
:----|----|
| Maximum Takeoff Weight(MTOW) | $Not~Exceed~8000~kg$ | 
| Capacity | $Up~to~8~passengers~in~total$ |
| Speed | $At~least~as~fast~as~other~similar~aircraft~in~the~market$ |
| Maximum Wingspan | $15.5~m$ |
| Maximum Payload | $Not~less~than~900~kg~with~minimum~450~kg~baggage$ | 
| Mission Range | $Nominal~mission~range~of~1500~nm$ | 
| Maximum Service Ceiling | $At~least~38,000~ft$ | 
| Certified Takeoff Distance at MTOW | $<1400~m~at~Sea~Level~ISA+15$ | 
| Certified Landing Distance with 8 Passenger (incl. luggage) and 100nm reserve fuel | $<1000m~at~Sea~Level~ISA+15$ |
| Maximum Rate of Climb (RC) at MTOW at sea level | $Must~not~be~less~than~2100ft/min$ |
| Certification | $Aircraft~must~be~certifiable~under~FAR-23~regulation$ |
---
You are also wishing to have a more fuel-efficient aircraft to reduce the impact to the environment while maintain high safety standard.
"

# ╔═╡ e7c1ad3b-33f2-45d5-8d66-7c99adc53d25
md"""
# Market Analysis
"""

# ╔═╡ 39ffd4ca-7905-4276-b0b6-20ae1c530097
md"

Our team researched similar spec'd aircraft on the current market and made references to the following aircrafts:

|**Parameters**| **Aircraft 1** |**Aircraft 2** | **Aircraft 3** |
:--|----|----|----|
| Model name | $Cessna~CJ3~G2$ |$~Embraer~Phenom~300$ | $~Hawker~400~XPr~$|
| Number of Pax |$2~crews+7~passengers$|$2~crew+7~passenger$|$2~crews+7passengers$|
| Max range | $2040~nm$ | $2077~nm$| $2160~nm$|
| Payload | $968~kg~with~454kg~baggage$|$1005~kg$|$953kg$|
| Maximum Takeoff Weight(MTOW) | $6291k~g$|$8150~kg$|$7394kg$|
| Cruise Speed | $416knots$|$453knots$|$447knots$|
| Cruising Altitude($h_\text{cruise}$) | $45000~ft$|$45000~ft$|$45000~ft$
| Engine type | $Williams~FJ44-3A$|$PW535E$|$Williams~FJ44-3A$|
| Thrust of one engine| $2820~lbf$|$3360~lbf$|$3200~lbf$|


"

# ╔═╡ ab589d30-531a-4f49-927c-739335fe3a7b
md"""
## Requirement Specification

General Requirements:
* Maximum takeoff weight(MTOW) must not exceed $8000$ kg
* Maximum wing span: $15.5$ m
* Maximum payload: ≥$900$ kg with minimum baggage capacity: $450$ kg
* Occupants: $8$ ($90$ kg pax + $10$ kg luggage)
Performance Requirements:
* Range: Medium-haul HKG to SIN, HKG to XCH
* Maximum service ceiling at MTOW: ≥ $11582$ m ($38000$ ft)
* Certified takeoff distance at MTOW: ≤ $1400$ m at Sea Level ISA+$15$
* Certified landing distance with $8$ occupants (incl. luggage) and $185$ km ($100$ nautical miles) reserve fuel must not exceed 1000 m at sea level ISA +$15$
* Maximum rate of climb (RC) at MTOW at sea level must not be less than $10.7$ m/s ($2100$ ft/min)
Certification Requirement:
* Aircraft must be certifiable under the FAR-23 regulation
"""

# ╔═╡ 6d1a05b0-9128-4e3c-887c-c4d43c57efac
md"""
# Initial Weight Estimation

**Author**: [Arjit SETH](mailto:ajseth@ust.hk), Research Assistant, MAE, HKUST.

![](https://raw.githubusercontent.com/HKUST-OCTAD-LAB/MECH3620Materials/main/pics/XDSMWeightEstimation.svg)
"""

# ╔═╡ 72747e12-4ab5-4090-8a51-b8747741b07e
begin
	g 					= 9.81 					# Gravitational acceleration constant
	WPL   	   			= (90*7+450)g 		    # Payload weight in N
	Woccupant 			= (90+10)*8g 			# Occupant weight in N
	Wcrew 				= (90+10)*1*g   		#Weight (N) for 1 Crew
	M 					= 0.76 					# Cruise speed in Mach
	Cruise_LD_Roskam 	= 11 					# From Roskam 10-12
	Loiter_LD_Roskam 	= 13 					# From Roskam 12-14
	Cruise_cT_Roskam 	= 0.7 					# From Roskam 0.5-0.9
	Loiter_cT_Roskam 	= 0.5 					# From Roskam 0.4-0.6
	#For jet aircraft, the cruise L/D is 86.6% of the maximum L/D. From Lecutre note
	LD_max 				= Cruise_LD_Roskam/0.866 # Maximum L/D ratio
	A_We_W0_Roskam 		=0.2678 				# From Roskam’s regression coefficents
	B_We_W0_Roskam 		=0.9979 				# From Roskam’s regression coefficents
	A_We_W0_Raymer 		=1.02 		 			#From Raymer’s regression coefficients
	C_We_W0_Raymer 		=-0.06 				    # From Raymer’s regression coefficients
	alt_ft = 36000 #cruise altitude (ft)
	alt_m = alt_ft/3.28084  #cruise altitude (m)
	rho_SL = 1.225
end;

# ╔═╡ 6932192d-758a-4133-956d-9c8f4fb3d306
md"#### Worst Case 12 Segment (VHHH to YPXM dirvert to WICC)
1. Engine Start & Warmup
2. Taxi
3. Take-off 
4. Climb
5. 1915 nm Long Range Cruise
6. Descent
7. 5 mins Loiter
8. Climb to 10,000 ft to alternate
9. 141nm cruise to alternate
10. Descent
11. 5 mins Loiter
12. Landing, Taxi, and Shut Down

"

# ╔═╡ 8cb6b156-1b2c-4a82-8d53-38a451ca04ed
md"#### Normal Case 8 Segment (VHHH to YPXM, Land with 141 nm reserve fuel)
1. Engine Start & Warmup
2. Taxi
3. Take-off 
4. Climb
5. 1915 nm Long Range Cruise
6. Descent
7. 5 mins Loiter
8. Landing, Taxi, and Shut Down

"

# ╔═╡ 81a0d772-9cc1-40ef-b31c-eb720f82f568
md"#### Cruise Weight Fraction Equation

$$WF_{\mathrm{cruise}} = \exp\left(-\frac{R \times SFC}{V \times (L/D)_\text{cruise}}\right)$$
The cruise lift-to-drag ratio can be approximated as $(L/D)_\text{cruise} = 0.866(L/D)_\max$.
"

# ╔═╡ 32115fbc-2ec8-40f9-bdb8-3826b1c969cb
cruiseWF(R, SFC, V, LD) = exp(-R * SFC/(V * LD));

# ╔═╡ 20b4bcb6-890e-4166-ae3b-d382a2a391f2
#Cruise 1 from VHHH to YPXM
begin
	# At 36,000 ft, speed of sound ≈ 310.02 m/s
	V_C1_W = M * 310.02       		# Cruise speed in m/s
	cruise_SFC1 = 0.8/3600 # TSFC at cruise in 1/secs (Fj44-4 SFC=0.8 with M=0.76 at 36,000ft)
	R1 = 1915 * 1852   			# Range of cruise segment 1
	LD_cruise1 = Cruise_LD_Roskam  # L/D ratio at cruise (From Roskam 10-12)
end;

# ╔═╡ 22d5bccc-6fcc-44c4-964b-a034025f84d1
cruise1FF = cruiseWF(R1, cruise_SFC1, V_C1_W, LD_cruise1)

# ╔═╡ 5ceca88b-642d-4b58-b680-b1d9e1365fb1
#Cruise 2 from YPXM to WICC 141nm at 10,000 ft dirvert
begin
	# At 10,000 ft, speed of sound ≈ 344.81 m/s
	V_C2_W = M * 344.81       		# Cruise speed in m/s
	cruise_SFC2 = 0.8/3600 		# TSFC at cruise in 1/secs (Fj44-4 SFC=0.8 with M=0.76 at 36,000ft)
	R2 = 141* 1852   			# Range of cruise segment 1
	LD_cruise2 = Cruise_LD_Roskam  # L/D ratio at cruise (From Roskam 10-12)
end;

# ╔═╡ 0cd381ea-ca89-4473-8d06-cffc47d33314
cruise2FF = cruiseWF(R2, cruise_SFC2, V_C2_W, LD_cruise2)

# ╔═╡ e3b80ea2-d8da-4a12-84d5-e7dcc7f98880
md"
### Loiter Weight Fraction

$$\left(\frac{W_4}{W_3}\right)_\text{loiter} = \exp\left(-\frac{E \times SFC}{(L/D)_\max}\right)$$
"

# ╔═╡ ea51288e-4199-4fda-b8ed-b9eacb1775b7
    loiter_weight_fraction(E, SFC, L_D) = exp(-E * SFC / L_D)

# ╔═╡ 1234b5e1-96e0-4c00-841c-44ba33f21caf
begin
	E = 5*60 # (sec) Loiter time 5 minutes	
	SFC_holding = 0.5/3600 	# Loiter Pattern SFC 
end;
	

# ╔═╡ 7a4cd613-6110-4483-891c-4a3ff7052052
loiter5min_FF = loiter_weight_fraction(E, SFC_holding, LD_max)

# ╔═╡ 470b1aa4-689b-47f4-8bad-3fbb6006f117
md"#### Aircraft Fuel fraction
"

# ╔═╡ f62e35b1-a487-4fd8-969d-184490572a22
#For Worst Case 12 Segment (VHHH to YPXM dirvert to WICC)
begin
	conf = set_pt_conf(tf = tf_markdown, alignment = :c);
	Aircraft_Fuel_Fraction_Data = [ "W1/WTO" "Engine Start & Warmup" 0.990 "R";
		"W2/W1" "Taxi" 0.995 "R";
		"W3/W2" "Take-off" 0.995 "R";
		"W4/W3" "Climb" 0.980 "R";
		"W5/W4" "Long Range Cruise" 0.737 "C";
		"W6/W5" "Descent" 0.990 "R";
		"W7/W6" "Loiter" 0.997 "C";
		"W8/W7" "Climb to 10,000ft to alternate" 0.990 "R";
		"W9/W8" "141nm cruise to alternate(WICC)" 0.980 "C";
		"W10/W9" "Descent" 0.995 "R";
		"W11/W10" "Loiter" 0.997 "C";
		"W12/W11" "Landing,taxi, and shut down" 0.992 "R";
		
		
	]
	Aircraft_Fuel_Fraction_Header = ["Wi+1/Wi", "Segment", "Fuel Fraction ", "R or C"]
end

# ╔═╡ 2f3521f7-438d-4d2f-99de-38f5f527f8a4
#Worst Case 12 Segment (VHHH to YPXM dirvert to WICC)
pretty_table(Aircraft_Fuel_Fraction_Data; header = Aircraft_Fuel_Fraction_Header )

# ╔═╡ a4fa5e98-9ed2-4724-b3e3-33d5add0077c
#For Worst Case 12 Segment (VHHH to YPXM dirvert to WICC)
begin
	EngineStart_WarmupFF = 0.99;  # From Roskam
	TaxiFF 				 = 0.995; # From Roskam
	TakeoffFF 			 = 0.995; # From Roskam
	Climb1FF 			 = 0.98;  # From Roskam
	LongRangeCruiseFF    = cruise1FF; # Calculated
	Descent1FF 			 = 0.99;  # From Roskam
	Loiter1FF  			 = loiter5min_FF; # Calculated
	Climb_AlternateFF 	 = 0.99;  # From Roskam
	Cruise_AlternateFF 	 = cruise2FF; # Calculated
	Descemt2FF 			 = 0.99;  # From Roskam
	Loiter2FF 			 = loiter5min_FF; # Calculated
	LandingFF  			 = 0.992; # From Roskam
	
end;

# ╔═╡ ccd459b2-39e0-4e25-94a4-1972705136f5
#For Normal Case 8 Segment (VHHH to YPXM, Land with 141 nm reserve fuel (RF))
begin
	RF_EngineStart_WarmupFF = 0.99;  # From Roskam
	RF_TaxiFF 				 = 0.995; # From Roskam
	RF_TakeoffFF 			 = 0.995; # From Roskam
	RF_Climb1FF 			 = 0.98;  # From Roskam
	RF_LongRangeCruiseFF    = cruise1FF; # Calculated
	RF_Descent1FF 			 = 0.99;  # From Roskam
	RF_Loiter1FF  			 = loiter5min_FF; # Calculated
	RF_LandingFF  			 = 0.992; # From Roskam
	
end;

# ╔═╡ ae3b7816-0968-4610-a207-50c893a7b0fe
print(Loiter2FF)

# ╔═╡ 78a67dff-0719-4fc2-a1dd-4097fc74d699
print(loiter5min_FF)

# ╔═╡ fbe1fe14-d209-4a6c-b82f-2d85faacaf0a
md"""## Fuel Weight Fractions
The fuel weight fraction is given by:
```math
W_{f_0} \equiv \frac{W_f}{W_0} = a\left(1 - \prod_{i = 1}^{N}\frac{W_{f_i}}{W_{f_{i-1}}}\right)
```
where the input $a$ is the additional fuel reserve (usually as a percentage of the total).
"""

# ╔═╡ 5ee13179-dd5e-46e6-8b14-2025a15b7f01
fuel_weight_fraction(fuel_fracs, a) = a * (1 - prod(fuel_fracs));

# ╔═╡ fc2bc97e-fd0c-4893-b09d-ef8330abe5b5
FFs =[EngineStart_WarmupFF,TaxiFF,TakeoffFF,Climb1FF,LongRangeCruiseFF,Descent1FF,Loiter1FF,Climb_AlternateFF,Cruise_AlternateFF,Descemt2FF,Loiter2FF,LandingFF];

# ╔═╡ a178cee5-55fe-4697-af21-ce3490e9dcb3
# Cumulative product for weight fractions over each mission segment
WFs_mission = cumprod(FFs);

# ╔═╡ 81863466-3919-4dc2-80cf-1d3011170537
RF_FFs= [RF_EngineStart_WarmupFF,RF_TaxiFF,RF_TakeoffFF,RF_Climb1FF,RF_LongRangeCruiseFF,RF_Descent1FF,RF_Loiter1FF,RF_LandingFF]

# ╔═╡ a4d8bf46-6d5c-40d8-a68a-665ea663b5bd
RF_WFs_mission = cumprod(RF_FFs)

# ╔═╡ 3cc38fd3-08a9-47e0-9f26-4801c27b465e
RF_EngineStart_WarmupWF,RF_TaxiWF,RF_TakeoffWF,RF_Climb1WF,RF_LongRangeCruiseWF,RF_Descent1WF,RF_Loiter1WF,RF_LandingWF = RF_WFs_mission

# ╔═╡ 69665064-c6f7-4638-a635-cff09e391561
md"Now we assign each number in the array to the corresponding mission segment's weight fraction variable."

# ╔═╡ cc48cfcb-06e2-4956-b7cb-fc7da79e3b1d
WF_EngineStart_Warmup,WF_Taxi,WF_Takeoff,WF_Climb1,WF_LongRangeCruise,WF_Descent1,WF_Loiter1,WF_Climb_Alternate,WF_Cruise_Alternate,WF_Descemt2,WF_Loiter2,WF_Landing = WFs_mission

# ╔═╡ d7a90ac7-afaf-4489-bdfe-2a8df4573520
print(WFs_mission)

# ╔═╡ b052907b-90a1-455c-9a2b-ee5d60ec94b5
a=1.06 #Additional trapped fuel

# ╔═╡ e5fd76c8-5fbe-4979-a54b-8003aeab4f14
WfWTO = fuel_weight_fraction(FFs, a) # Estimated fuel-weight fraction

# ╔═╡ 741496ed-94ab-48f9-a625-6f94c8b276f8
plot( 
	eachindex(FFs), # Mission segment numbers
	cumprod(FFs), # Cumulative fuel fractions
	xlabel = "Mission Segment Number", 
	ylabel = "Fuel Fraction", 
	label = ""
)

# ╔═╡ 352536d4-805b-4083-856b-ca5ddb8138ea
md"""## Empty Weight Fraction
"""

# ╔═╡ 32709885-a25e-4195-855b-3f21b28d9c7a
html"""
<h5>Roskam's regrssion coefficient</h5>

<img src="https://raw.githubusercontent.com/KulaiZeon/3620/main/linear%20regres.jpg?token=GHSAT0AAAAAACP3AMFCGLJ2TTMGCRFQQJAAZP2VIVA"

>
"""

# ╔═╡ 32eb82e3-6c50-4c57-8b07-edefe7dd3f74
empty_weight_raymer(WTO, A, B) = A * WTO^B

# ╔═╡ e0943d16-1c6e-41e7-9f8b-6969ba70ea57
Aroskam, Broskam = 0.97, -0.06 #Raymer coefficient

# ╔═╡ 71be7d65-bf13-4f4c-972a-ed269dac0605
WTO_range = 5000:500:10000 # kg

# ╔═╡ d90ab36e-95ca-4de1-b9f6-a2edf75b4387
WeWTO_range = empty_weight_raymer.(WTO_range .* g, Aroskam,Broskam) # Broadcasting over range

# ╔═╡ 2a1e4c38-8763-460b-a343-39a74e4777fe
plot(
	WTO_range, # x-values (Takeoff weights)
	WeWTO_range, # y-values (Empty weight ratios) 
	xlabel = "Takeoff Weight", 
	ylabel = "Empty Weight / Takeoff Weight", 
	label = ""
)

# ╔═╡ e67e0ab1-316f-4da9-9a7f-d86f6eb6721a
md"""### Fixed-Point Iteration
We need to solve the following equation for $W_0$:
```math
\begin{align}
W_0 & = \frac{W_\text{payload} + W_\text{crew}}{1 - \displaystyle\frac{W_f}{W_0} - \displaystyle\frac{W_e}{W_0}},
\end{align}
```
where
```math
\begin{align}
\text{Fuel Weight Fraction:}  &\quad  & \frac{W_f}{W_0} \equiv W_{f_0} & = a\left(1 - \prod_{i = 1}^{N}\frac{W_{f_i}}{W_{f_{i-1}}}\right), \\
\text{Empty Weight Fraction:} &\quad & \frac{W_e}{W_0} \equiv W_{EF}(W_0) & = AW_0^B.
\end{align}
```

To numerically solve the equation, you can:

1. Begin with a guess for $W_0$, insert it into the right-hand expression and check the computed value to get the left-hand side, a new value of $W_0$. 
2. If you insert this new value of $W_0$ into the right-hand side again, you will get another new value for $W_0$.
3. Repeat the process for more iterations. Eventually, the value of $W_0$ should converge to a _fixed point_.


Here, we will denote the iteration number of a variable by an additional subscript $(-)_n$:
```math
\begin{align}
\text{Takeoff Weight Iteration:} & \quad & (W_0)_n & = \frac{W_\text{payload} + W_\text{crew}}{1 - W_{f_0} - W_{EF}[(W_0)_{n-1}]}\\
% \text{Equality:} & \quad & (W_0)_n & = (W_0)_{n-1}
\end{align}
```
So, we need to evaluate the right-hand expression to obtain the value of $W_0$ for the $n^\text{th}$ iteration, and compare it to the value of $W_0$ in the $(n-1)^{\text{th}}$ iteration.

Let the following indicate the relative error for the $n$th iteration:
```math
\varepsilon_n = \left|\frac{(W_0)_n - (W_0)_{n-1}}{(W_0)_{n-1}}\right|
```

We would like our analysis to converge below some tolerance $\varepsilon_\text{tol}$, i.e. the error should be $\varepsilon_{n} < \varepsilon_\text{tol}$.
"""

# ╔═╡ 0908bf03-986f-49a5-b606-04f0736a92ae
max_iter = 20;

# ╔═╡ 723789d3-7289-4d8f-88dd-320ff28f5711
W0 = WPL + Wcrew # From Requirement, Newtons

# ╔═╡ 4d23c2b9-55fb-430f-989d-3657476a77bc
begin
	num_slider = @bind num NumberField(1:max_iter, default = 6)
	md"""
	Number of iterations: `num` = $(num_slider)
	"""
end

# ╔═╡ db2054e7-89ba-4107-b85f-ca6294e3d683
md"""
## Maximum Takeoff Weight
![](https://raw.githubusercontent.com/HKUST-OCTAD-LAB/MECH3620Materials/main/pics/XDSMTakeoff.svg)

The 'governing equation' of this problem is:

```math
W_0 = \frac{W_\text{payload} + W_\text{crew}}{1 - \displaystyle\frac{W_f}{W_0} - \displaystyle\frac{W_e}{W_0}}
```


So we need to compute the maximum takeoff weight given payload weight, crew weight, fuel-weight fraction, and empty-weight fraction. We will compute this by writing the following function:

"""

# ╔═╡ c054c67d-b358-4c0d-9f39-d6894d1e1073
maximum_takeoff_weight(WPL, Woccupant, WfWTO, WeWTO) = (WPL + Woccupant)/(1 - WfWTO - WeWTO)

# ╔═╡ 923836cf-2ff3-4055-b773-304eb7a7148b
function compute_maximum_takeoff_weight(
		W_0, W_PL, W_crew, WfWTO, A, B; # Input arguments
		# Named default arguments
		num_iters = 20, # Number of iterations
		tol = 1e-12 	# Convergence tolerance
	)
	
	# Initial value of maximum takeoff weight (WTO) from guess
	WTO = W_0
	
	# Array of takeoff weight values
	WTOs = [WTO]
	
	# Array of errors over iterations of size num_iters, initially infinite
	errors = [ Inf; zeros(num_iters) ]
	
	# Iterative loop
	for i in 2:num_iters
		# Calculate empty weight fraction
		WeWTO = empty_weight_raymer(WTO, A, B)
		
		# Calculate new WTO with the calculated empty weight fraction
		new_WTO = maximum_takeoff_weight(W_PL, W_crew, WfWTO, WeWTO)
		
		# Evaluate relative error
		error = abs((new_WTO - WTO)/WTO)

		# Append new WTO to WTOs array
		push!(WTOs, new_WTO)
		
		# Assign error to errors array at current index
		errors[i] = error
		
		# Conditional
		if error < tol					
			break # Break loop
		else
			# Assign new takeoff weight to WTO
			WTO = new_WTO
		end
	end
	
	# Return arrays of takeoff weights and errors 
	WTOs, errors[1:length(WTOs)]
end

# ╔═╡ 5cede6db-12db-4a2d-989f-886fea72e08c
WTOs, errors = compute_maximum_takeoff_weight(
					W0, WPL, Wcrew, WfWTO, Aroskam, Broskam;
					num_iters = num, 
					tol = 1e-12
				   );

# ╔═╡ 59bd07fd-f430-4e54-91cb-38507a96fad5
WTOs

# ╔═╡ ee9bfa60-2883-4a7a-8900-f4d4a05408e8
MTOW_kg = WTOs[end] / g # kg

# ╔═╡ e677c58d-bae9-4716-9088-6279e45ca478
begin
	W_total_fuel_kg = WfWTO*MTOW_kg 					# (kg) Total Fuel Weight
	W_actual_fuel_kg = W_total_fuel_kg / 1.06 			# (kg) Usable Fuel Weight
	W_trapped_fuel_kg = W_total_fuel_kg - W_actual_fuel_kg
 	W_crew_kg = Wcrew/g									# (kg) Crew Weight
	W_payload_kg = WPL/g 								# (kg) Payload
	W_empty_kg = MTOW_kg - W_total_fuel_kg - W_crew_kg - W_payload_kg  	# (kg) Empty Weight
	W_OEW_kg = W_empty_kg + W_crew_kg + W_trapped_fuel_kg
	W_usable_fuel_kg = W_total_fuel_kg - W_trapped_fuel_kg
	W_ZFW_kg = MTOW_kg - W_usable_fuel_kg
	
end

# ╔═╡ 0b409b30-cb9c-4500-8099-6e863ee34dd7
print(W_trapped_fuel_kg)

# ╔═╡ 5b1c0694-e148-4886-a3db-7a7db1c2d89f
begin
	Expected_Weight_Data = ["MTOW - Maximum Take-Off Weight" MTOW_kg ;
		"ZFW - Zero-fuel Weight" W_ZFW_kg;
		"OEW - Operating Empty Weight" W_OEW_kg;
		"MEW - Manufacturer’s Empty Weight" W_empty_kg;
		"Total Fuel Weight" W_total_fuel_kg;
		"Usable Fuel Weight" W_actual_fuel_kg;
		"Trapped Fuel Weight" W_trapped_fuel_kg;
		"Crew Weight" W_crew_kg;
		"Payload" W_payload_kg;
		
	
	]
	Expected_Weight_Header = ["Expected Weight Type", "Expected Value in kg"]
end

# ╔═╡ 819934df-9768-472e-a820-7ebdabd70601
pretty_table(Expected_Weight_Data; header = Expected_Weight_Header )
#Need to run the code or you can not see the pretty table :)

# ╔═╡ 3b1aa5f5-91fe-4bca-8b9d-0e1f9a4fb0d9
begin
	plot1 = plot(WTOs, 
		label = "", 
		ylabel = "MTOW (N)", 
		xlabel = "Iterations"
	)
	plot2 = plot(errors,
		label = "", 
		ylabel = "Error, ε", 
		yscale = :log10, 
		xlabel = "Iterations"
	)
	
	plot(plot1, plot2, layout = (2,1))
end

# ╔═╡ 83123058-65dc-4177-9102-8f53f49ad6ac
md"####  Bréguet range equation

"

# ╔═╡ f6d6e4b4-e371-4fc1-bdb1-07834094b131
md"""
# Preliminary Sizing
"""

# ╔═╡ bc078e40-91ae-49f6-9136-0a89c3d99ed2
html"""
<h5>Roskam's Wetted area coefficient</h5>

<img src="https://github.com/KulaiZeon/PaP2jHU1e9/blob/main/wetS.png?raw=true"

>
"""

# ╔═╡ 824adc9c-ee04-4125-9406-d53093cac092
md"####  Estimating the wetted area S_wet
```math
S_\text{wet} = 10^cW^d_\text{0}
```
"

# ╔═╡ ae4797ca-7d3a-4134-8154-5b50cd9a7851
begin
	S_wet_c= 0.2263 	
	S_wet_d=0.6977
	#From Jan Roskam. Airplane Design, Volume 1–8. Roskam Aviation and Engineering Corporations, 1989. for business jet
end

# ╔═╡ 6c0369c2-947e-4110-af30-5741834ad178
S_wet_raymer(MTWO_kg, S_wet_c, S_wet_d)=(10)^(S_wet_c)*(MTOW_kg)^(S_wet_d)

# ╔═╡ e798a74a-48b0-4651-9ba4-90055e9ca5bb
Estimated_S_wet=S_wet_raymer.(MTOW_kg, S_wet_c, S_wet_d)

# ╔═╡ 5db9b815-ea70-4e2d-b7b7-e9eee677c6e3
md"####  Equivalent Parasite Area
```math
f = C_\text{f}S_\text{wet}
```
"

# ╔═╡ 68954d61-bdcb-41dc-8ea8-93112d8cf240
html"""
<h5>Raymer's friction coefficient</h5>

<img src="https://github.com/KulaiZeon/PaP2jHU1e9/blob/main/Raymer%20Cf.png?raw=true"

>
"""

# ╔═╡ 4ccb3b35-9da3-4abf-bf8b-67493cdcab3c
begin
	C_f= 0.0026 # Data from Raymer
Equivalent_parasite_area= C_f * Estimated_S_wet
	end

# ╔═╡ 89989cf6-a764-4e88-bd1c-865e2b447a00
md"""
We calculate the specification of our aircraft to be as follows:
"""

# ╔═╡ e1a52f37-988c-44fa-a84f-b7ebb5b06b41
md"""
	1. Aspect Ratio (We make reference to the CJ3 G2 aircraft):

```math
Aspect ~ Ratio ~ (AR) = \frac{b^2}{s}
```
	"""

# ╔═╡ 85ddc1ce-c661-46f5-9e2a-46171bfa40c0
md"""
	Substituting the specification of CJ3 G2 into the equation:

```math
AR_(CJ3) = \frac{16.26^2}{27.32}
```
	"""

# ╔═╡ fe703a8b-5e4b-4e34-9799-36e549b5c36e
begin
	CJ3_WingSpan = 16.26 #In meters
	CJ3_WingArea = 27.32 #In meters-squared
	CJ3_AR = CJ3_WingSpan^2 / CJ3_WingArea 
	println("The target aspect ratio is: ",CJ3_AR)
end

# ╔═╡ f1f3f858-36b7-4c0e-bbec-a568d784a938
md"""
	Substituting the specification of RJet into the equation:

```math
Wing~Area~(RJet) = \frac{15.5^2}{9.68}
```
	"""

# ╔═╡ 15cbf64f-4c23-4062-9a56-204f2e9f6a88
begin
	Rjet_AR = CJ3_AR
	Rjet_WingSpan = 15.5 #In meters
	Rjet_WingArea = Rjet_WingSpan^2 / Rjet_AR 
	println("The target wing area is: ",Rjet_WingArea,"m^2")
end

# ╔═╡ 9e89ce7e-7f9a-4bb1-bf78-f04d3cee4c94
md"""
	3. Wing Loading:

```math
Wing~Loading~(RJet) = \frac{MTOW}{Wing~Area}
```
	"""

# ╔═╡ cf9f2f74-1f35-4e84-8641-e000c8a4bbbd
md"""
	Substituting the specification of RJet into the equation:

```math
Wing~Loading~(RJet) = \frac{7862.16kg}{24.82m^2}
```
	"""

# ╔═╡ 271bae14-4da8-4cd9-b68c-7321c14f8fe7
begin
	Rjet_WingLoading = MTOW_kg / Rjet_WingArea 
	println("The target wing loading is: ",Rjet_WingLoading," in Kilograms per square metre.")
	println("The target wing loading is: ",Rjet_WingLoading*9.81," in Newtons per square metre.")
end

# ╔═╡ d6e10fea-3ed7-408e-9940-06d951031fcf
md"""


Based on our mission requirement, and making reference to the reference aircraft of Cessna CJ3 Gen 2, we deduce the appropriate specification of our aircraft to be as follows:

| **Parameter** | **Value (Metric)** | **Value (Imperial)** |
:-------------|-----------------------|-----------------------
| Aspect Ratio ($AR$) | $9.68$ | $9.68$ |
| Span ($b$) | $15.5~m$ | $50.82~ft$ |
| Wing Area ($S$) | $24.82~m^2$ | $267.1~ft^2$ |
| MTOW ($W_0$) | $7862.16~kg$ | $17333~lbs$ |
| Takeoff Wing Loading $(W/S)_\text{takeoff}$ | $265.1077~kg/m^2$ | $54.31~lbs/ft^2$ |
| Cruise Mach Number $(M_\text{cruise})$ | $0.76$ | $0.76$ |
| Cruise Altitude ($h_\text{cruise}$) | $10973~m$ | $36,000~ft$ |
| Ceiling Altitude ($h_\text{ceiling}$) | $13716~m$ | $45,000~ft$ |
---

"""

# ╔═╡ 7a3d8afc-0813-441b-90c0-f22642f145ec
gr( # Change to plotlyjs() for interactivity
	grid = true, 	   # Disable the grid for a e s t h e t i c
	size = (800, 520), # Adjust the dimensions to suit your monitor
	dpi = 300     	   # Higher DPI = higher density
)

# ╔═╡ 111eaa73-1d65-4692-823a-31ecc12b66dd
md"## Drag Polar"

# ╔═╡ c0a17500-521b-4728-84d3-74c1cf149249
md"""
### Induced Drag Coefficient

```math
k = \frac{1}{\pi e AR}
```
"""

# ╔═╡ df354ce7-e6f6-47ab-baba-2132412c7c79
induced_drag_coefficient(e, AR) = 1 / (pi * e * AR)

# ╔═╡ 59270c9e-b34e-4527-a0bd-5590bb5c7612
md"""
### Plot size and colour change """

# ╔═╡ b2b578d6-a078-4506-a812-5782255c78ca
gr(
	size = (900, 700),  # INCREASE THE SIZE FOR THE PLOTS HERE.
	palette = :tab20    # Color scheme for the lines and markers in plots
)

# ╔═╡ 685758b9-fbe5-4cd1-99ba-227b025ace6e
md"""
### Parabolic Drag Polar

```math
C_D = C_{D_\min} + k\left(C_L - C_{L_{\text{min drag}}}\right)^2, \quad k = \frac{1}{\pi e AR}
```
"""

# ╔═╡ a77e6278-68f6-494c-9010-9b07a7c471bc
drag_polar(CD0, k, CL, CL0) = CD0 + k * (CL - CL0)^2;

# ╔═╡ 3170a1b9-bf5e-42b4-9521-f7193bb5fb6c
md"""
### CD0 and e Settings (using This setting)
CD0 and e with Changes in Flaps Configuration
The zero-lift drag coefficient $C_{D_0}$ and span efficiency factor $e$ change with the configuration of flaps.

```math
C_{D_0} + \Delta C_{D_0}
```

| Configuration | $\Delta C_{D_0}$ | $e$ |
:---------------|-----------------|-----|
Flaps at $0^\circ$ | $0 | $0.85 |
Flaps at $5^\circ$, gear down | $0.035 | $0.8 |
Flaps at $5^\circ$, gear up | $0.01 | $0.8 |
Flaps at $10^\circ$, gear down | $0.045 | $0.75 |
Flaps at $10^\circ$, gear up | $0.02 | $0.75 |
Flaps at $15^\circ$, gear down | $0.055 | $0.7 |
Flaps at $15^\circ$, gear up | $0.03 | $0.7 |
"""

# ╔═╡ 6ecae78a-5967-4e16-b932-6ec649624b96
md"Defining a range of lift coefficients over which we would like to see the variation of the drag polar."

# ╔═╡ 1efaccbd-abb6-4637-847b-cfad9fe8b413
cls = -1.5:0.05:1.5

# ╔═╡ e1776759-bd25-48d5-9753-7efbb8f81b1f
md"## Constraint Analysis"

# ╔═╡ a4bf5b5c-d4b7-4736-ad8d-b4a46a4e16f2
html"""
<h5>Clmax</h5>

<img src="https://github.com/KulaiZeon/PaP2jHU1e9/blob/main/Clmax.png?raw=true"

>
"""

# ╔═╡ d75674aa-23ad-4a3d-b936-1a8a613035f7
md"### Stall Speed

Dynamic pressure:

```math
q = \frac{1}{2} \rho V^2
```

Stall speed:

```math
\left(\frac{W}{S}\right)_\text{stall} = \frac{1}{2}\rho V_\text{stall}^2 C_{L_\max} 
```

"

# ╔═╡ 6b7ed88d-a9c0-4a17-9816-6244c34065c8
dynamic_pressure(rho, V) = 1/2 * rho * V^2

# ╔═╡ ea4a050e-2029-4c74-a631-175622fcc308
wing_loading_stall_speed(V_stall, CL_max, ρ = 1.225) = dynamic_pressure(ρ, V_stall) * CL_max

# ╔═╡ f46d9a0a-ecc6-45fa-82fa-bd7c029d3c6a
begin
	### The value 85 knots is simply reference from CJ3 stall speed (83 knots), this value should be revisited. Approach speed will be 1.3 stall speed which is 110.5 knots
	V_stall = 0.514 * 85  # 85 knots to m/s
	CL_max_2_0 = 2.0 		  # Maximum lift coefficient with Landing Configuration
	CL_max_2_2 = 2.2
	CL_max_2_4 = 2.4
	CL_max_2_6 = 2.6
end;

# ╔═╡ 4a0ec6ac-5b7b-4ab1-bfd8-e267f54cdee1
rho_CX = 1.13314 # Christmas island Airport(YPXM) Air denisty at sea level ISA +15

# ╔═╡ e61bdfbc-4dfe-4ee9-9c43-e4f056e18131
WbS_stall_2_0 = wing_loading_stall_speed(V_stall, CL_max_2_0, rho_CX) 

# ╔═╡ 4802362f-feb1-41b7-915d-3efec537b1b1
WbS_stall_2_2 = wing_loading_stall_speed(V_stall, CL_max_2_2, rho_CX) 

# ╔═╡ b18d94d2-baa3-46c4-adc0-cdf43630aa3d
WbS_stall_2_4 = wing_loading_stall_speed(V_stall, CL_max_2_4, rho_CX) 

# ╔═╡ 59839dae-8a32-42cb-9d8c-fd019b65c15b
WbS_stall_2_6 = wing_loading_stall_speed(V_stall, CL_max_2_6, rho_CX) 

# ╔═╡ ccaae600-470a-4502-ae9c-05abe854d2fa
md"We need to plot a vertical line, so we define an array with the same elements repeated using the `fill()` function."

# ╔═╡ 86306938-c822-4dcc-914a-cebbccd97387
n = 15

# ╔═╡ 800abc8e-e07e-465e-a033-89f504d13f9f
begin
	stalls_2_0 = fill(WbS_stall_2_0, n);
	stalls_2_2 = fill(WbS_stall_2_2, n);
	stalls_2_4 = fill(WbS_stall_2_4, n);
	stalls_2_6 = fill(WbS_stall_2_6, n);
end

# ╔═╡ af980183-f0d5-457c-bb6d-1204654cc306
TbWs = range(0, 0.5, length = n);

# ╔═╡ dd3b0468-e323-4d88-a209-f9f85c261956
begin 
	plot(xlabel = "W/S, N/m²", ylabel = "T/W", title = "Matching Chart", xlim = (0, 6000))
	plot!(stalls_2_0, TbWs, label = "Stall CLmax2.0")
	plot!(stalls_2_2, TbWs, label = "Stall CLmax2.2")
	plot!(stalls_2_4, TbWs, label = "Stall CLmax2.4")
	plot!(stalls_2_6, TbWs, label = "Stall CLmax2.6")
	annotate!(1250, 0.2, "Feasible")
	annotate!(4000, 0.2, "Infeasible")
end

# ╔═╡ 88a5a5ab-c229-4a0c-9043-9b0d84879d79
md"### Takeoff

Trust-to-Weight ratio for takeoff stage:

```math
\left(\frac{T}{W}\right)_\text{Takeoff} = \frac{0.0929}{4.448}\ \frac{W_0/S_\text{ref}}{(\rho/\rho_\text{SL})C_\text{max,TO}TOP} \quad (SI)
```
"

# ╔═╡ 11243aaf-517e-4313-8222-4866f2249d42
html"""
<h5>TOP</h5>

<img src="https://github.com/KulaiZeon/PaP2jHU1e9/blob/main/TOP.png?raw=true"

>
"""

# ╔═╡ 6396f027-3e40-4837-82c1-f3ce01aa6d19
md"""

Using Raymer's chart for the takeoff condition:

```math
\frac{(W_0/S)}{\sigma C_{L_{TO}}(T_0/W_0)} \leq TOP = 250
```

"""

# ╔═╡ 2d9dc8f3-326a-436f-916d-02f8483a815f
takeoff_condition(WbS, σ, CL_takeoff, TOP) = (0.0929/4.448) * WbS / (TOP * σ * CL_takeoff)

# ╔═╡ e9a58566-aa42-41de-ba6f-8bc5bea5e8a7
begin
	CL_takeoff_1_6 = 1.6
	CL_takeoff_1_7 = 1.7
	CL_takeoff_1_8 = 1.8
	CL_takeoff_1_9 = 1.9
	CL_takeoff_2_0 = 2.0
	CL_takeoff_2_1 = 2.1
	CL_takeoff_2_2 = 2.2

	TOP = 250 # should be 185 according to lec
	rho_HK = 1.16346 #Hong Kong Airport(VHHH) air density at ISA +15
end;

# ╔═╡ 45dde11f-b878-4ce3-88c7-9f3fdd7c109f
wing_loadings = 0:10000;

# ╔═╡ 52ae46d9-576e-4224-bfe4-04daa6990c76
begin
	TbW_takeoff_1_6= takeoff_condition.(wing_loadings, rho_HK, CL_takeoff_1_6, TOP)
	TbW_takeoff_1_7= takeoff_condition.(wing_loadings, rho_HK, CL_takeoff_1_7, TOP)
	TbW_takeoff_1_8= takeoff_condition.(wing_loadings, rho_HK, CL_takeoff_1_8, TOP)
	TbW_takeoff_1_9= takeoff_condition.(wing_loadings, rho_HK, CL_takeoff_1_9, TOP)
	TbW_takeoff_2_0= takeoff_condition.(wing_loadings, rho_HK, CL_takeoff_2_0, TOP)
	TbW_takeoff_2_1= takeoff_condition.(wing_loadings, rho_HK, CL_takeoff_2_1, TOP)
	TbW_takeoff_2_2= takeoff_condition.(wing_loadings, rho_HK, CL_takeoff_2_2, TOP)
end

# ╔═╡ 9ba45a64-57aa-4841-b7b1-d0a42ac8a963
begin 
	plot(xlabel = "W/S, N/m²", ylabel = "T/W", title = "Matching Chart", xlim = (0, 6000))
	plot!(stalls_2_0, TbWs, label = "Stall CLmax2.0")
	plot!(stalls_2_2, TbWs, label = "Stall CLmax2.2")
	plot!(stalls_2_4, TbWs, label = "Stall CLmax2.4")
	plot!(stalls_2_6, TbWs, label = "Stall CLmax2.6")
	plot!(wing_loadings, TbW_takeoff_1_6, label = "Takeoff CLmaxTO 1.6")
	plot!(wing_loadings, TbW_takeoff_1_7, label = "Takeoff CLmaxTO 1.7")
	plot!(wing_loadings, TbW_takeoff_1_8, label = "Takeoff CLmaxTO 1.8")
	plot!(wing_loadings, TbW_takeoff_1_9, label = "Takeoff CLmaxTO 1.9")
	plot!(wing_loadings, TbW_takeoff_2_0, label = "Takeoff CLmaxTO 2.0")
	plot!(wing_loadings, TbW_takeoff_2_1, label = "Takeoff CLmaxTO 2.1")
	plot!(wing_loadings, TbW_takeoff_2_2, label = "Takeoff CLmaxTO 2.2")
	annotate!(1250, 0.2, "Feasible")
	annotate!(4000, 0.1, "Infeasible")
end

# ╔═╡ e03fe34a-d08b-41fd-b7f8-19934fe838be
md"""### Landing

```math
\frac{W_0}{S} = \sigma \left(\frac{W_0}{W_L}\right)g\left[\frac{C_{L_\max, L}}{5}\left(0.6s_\text{FL} - s_a\right)\right]
```

The $\color{orange} g$ is included to convert the weight's units into Newtons.
"""

# ╔═╡ a53bc6f4-9b90-428f-90db-3cf1265abccd
landing_condition(σ, CL_max, s_FL, s_a, r = 0.6, g = 9.81) = σ * g * (CL_max /5) * (r * s_FL - s_a)

# ╔═╡ cf6282e5-5130-45ee-8161-9924e76def2d
V_approach= 1.3* V_stall

# ╔═╡ 7e5c95b8-824e-4c24-ae7d-51a64c40258a
begin
	CL_landing = 2.3 # Maximum lift coefficient at landing
	s_FL = 2100	# Landing field length (Total landing distance) (XCH=2300m)
	s_a = 183 # Approach distance (m)
	r = 0.6 # FAR-25 condition
end

# ╔═╡ 4850ade4-87b2-4cfb-8e75-b28363a3bb6e
landing_sls = 1/RF_LandingWF * landing_condition(rho_CX/1.225, CL_landing, s_FL, s_a, r) 

##Should using total weight fraction not fuel fraction! (corrected)

# ╔═╡ 936fa626-d99a-4d37-910b-dc549bc1caeb
wbs_landing = fill(landing_sls, n);

# ╔═╡ 8f882e5f-2736-4140-b984-0f8b1667963a
begin 
	plot(xlabel = "W/S, N/m²", ylabel = "T/W", title = "Matching Chart", xlim = (0, 9000))
	plot!(stalls_2_0, TbWs, label = "Stall CLmax2.0")
	plot!(stalls_2_2, TbWs, label = "Stall CLmax2.2")
	plot!(stalls_2_4, TbWs, label = "Stall CLmax2.4")
	plot!(stalls_2_6, TbWs, label = "Stall CLmax2.6")
	plot!(wing_loadings, TbW_takeoff_1_6, label = "Takeoff CLmaxTO 1.6")
	plot!(wing_loadings, TbW_takeoff_1_7, label = "Takeoff CLmaxTO 1.7")
	plot!(wing_loadings, TbW_takeoff_1_8, label = "Takeoff CLmaxTO 1.8")
	plot!(wing_loadings, TbW_takeoff_1_9, label = "Takeoff CLmaxTO 1.9")
	plot!(wing_loadings, TbW_takeoff_2_0, label = "Takeoff CLmaxTO 2.0")
	plot!(wing_loadings, TbW_takeoff_2_1, label = "Takeoff CLmaxTO 2.1")
	plot!(wing_loadings, TbW_takeoff_2_2, label = "Takeoff CLmaxTO 2.2")
	plot!(wbs_landing, TbWs, label = "Landing")
	annotate!(1250, 0.2, "Feasible")
	annotate!(4000, 0.1, "Infeasible")
end

# ╔═╡ 9b3c70a9-cd79-45d9-a7aa-9eed24d4b49f
md"""### Climb Constraints

The general climb formula is:

```math
\left(\frac{T}{W}\right)_\text{climb} = \frac{k_s^2}{C_{L_\text{max,climb}}}C_{D_0} + k\frac{C_{L_\text{max,climb}}}{k_s^2} + G, \quad k_s = \frac{V}{V_\text{stall}}, k = \frac{1}{\pi e AR}
```

Applying the *thrust correction factors*:

```math
\left(\frac{T}{W}\right)_\text{takeoff} = \left(\frac{1}{0.8}\right){\color{blue} \left(\frac{1}{0.94}\right) \left(\frac{N_\text{engines}}{N_\text{engines} - 1}\right)\left(\frac{W}{W_\text{takeoff}}\right) } \left(\frac{T}{W}\right)_\text{climb}
```

The factors highlighted in orange are omitted when the engine is not at maximum continuous thrust, or not in an OEI condition, or when $W = W_\text{takeoff}$ respectively.
"""

# ╔═╡ c3e0bbc2-0070-4fed-b03b-dbee8259345a
climb_condition(k_s, CD0, CL_max, k, G) = (k_s^2 / CL_max) * CD0 + k * CL_max / k_s^2 + G

# ╔═╡ c0cc4d83-7522-4816-88de-2cd77a5b8893
function thrust_corrected_climb(k_s, CD0, CL_max, K, G, n_eng, # Necessary inputs
		weight_factor = 1; # Optional input with default = 1
		MCT = false, OEI = false # Named arguments
	) 
	 
	OEI_factor = ifelse(OEI, n_eng / (n_eng - 1), 1) # One-engine-out factor
	MCT_factor = ifelse(MCT, 1 / 0.94, 1) # Maximum continuous thrust factor
	
	(1 / 0.8) * MCT_factor * OEI_factor * weight_factor * climb_condition(k_s, CD0, CL_max, K, G)
end

# ╔═╡ 9c8505e4-e321-4003-85c5-95145094a487
begin
	CL_max_climb = 2.2  # Maximum climb lift coefficient
	n_eng 		 = 2 	# Number of engines
	AR 			 = 9.68  # Aspect ratio of wing
end;

# ╔═╡ 7b4223db-197f-4796-ace1-b32bf40dac28
md"""

| **Rules** | **Climb Conditions** | **ks** | **G(%)** |**Wing Configuratoin**|**Weight Configuratoin**|
:-------------|-----------------------|-----------------------|-----------------------|-----------------------|-----------------------|
| $23.66$ | takeoff climb OEI | >1.2 |>1.2 | takeoff flaps, gear down | MTOW |
| $23.67$ | Climb OEI | >1.2 |>1.2 | flaps retracted, gear up|MTOW|
| $23.69$ | enroute climb OEI | >1.2 |>1.2 | flaps retracted, gear up|MTOW|
| $23.77$ | bulked landing climb| >1.3 |>2.5 |landing flaps, gear down| MLW|


"""

# ╔═╡ eb6d8e61-83ce-46a4-8726-0b56a73a44bc
md"""

| **Rules** | **Climb Conditions** | **ks** | **G(%)** |**Wing Configuratoin**|**Weight Configuratoin**|
:-------------|-----------------------|-----------------------|-----------------------|-----------------------|-----------------------|
| $25.111$ | takeoff climb OEI | =1.2 | >1.2 | takeoff flaps, gear up | MTOW |
| $25.121$ | transition sement climb OEI | 1.1-1.2 | >0 | takeoff flaps, landing gear down|MTOW|
| $25.121$ | second segment climb OEI | =1.2  |>2.4 | takeoff flaps, gear up|MTOW|
| $25.121$| enroute climb OIE| =1.25 |>1.2 |retracted flaps, gears up| MTOW|
| $25.121$| balked landing climb OEI |  = 1.5 |>2.1 | Approach flaps, landing gear down |MLW|
| $25.119$ | bulked landing climb AEO| =1.3 | >3.2 |landing flaps, gear down| MLW|


"""

# ╔═╡ 6a82433e-4c81-4a27-9bd2-fa8bd957c28d
md"""

### CD0 and e Settings (just for reference)


| **Configuration** | **$\Delta C_{D_0}$** | **$e$** |
:---------------|-----------------|--------|
|clean(no flaps)|0|0.80-0.85|
|takeoff flaps|0.010-0.020|0.75-0.8|
|landing flaps|0.055-0.075|0.70-0.75|
|landing gear(up)|0.015-0.025|no effect|

For the takeoff and landing flaps, we typically use the smaller CD0 for gear up and the larger one for gear down
"""

# ╔═╡ a56deffb-315b-4031-8086-23ea9e8954c9
md"""
### CD0 and e Settings (using This setting)
CD0 and e with Changes in Flaps Configuration
The zero-lift drag coefficient $C_{D_0}$ and span efficiency factor $e$ change with the configuration of flaps.

```math
C_{D_0} + \Delta C_{D_0}
```

| Configuration | $\Delta C_{D_0}$ | $e$ |
:---------------|-----------------|-----|
Flaps at $0^\circ$ | $0 | $0.85 |
Flaps at $5^\circ$, gear down | $0.035 | $0.8 |
Flaps at $5^\circ$, gear up | $0.01 | $0.8 |
Flaps at $10^\circ$, gear down | $0.045 | $0.75 |
Flaps at $10^\circ$, gear up | $0.02 | $0.75 |
Flaps at $15^\circ$, gear down | $0.055 | $0.7 |
Flaps at $15^\circ$, gear up | $0.03 | $0.7 |
"""

# ╔═╡ 88bb05ff-ddc8-43f4-8835-ec121f182c57
begin
	# Flaps at 0 deg (Cruise)
	e_0deg  = 0.85
	ΔCD0_0deg_up = 0 # Clean

	# Flaps at 5 deg (Take-off)
	e_5deg  = 0.8
	ΔCD0_5deg_down = 0.035 # Gear Down
	ΔCD0_5deg_up =  0.01 # Gear Up
	
	# Flaps at 10 deg (Approach)
	e_10deg = 0.75 
	ΔCD0_10deg_down = 0.045 # Gear Down
	ΔCD0_10deg_up =  0.02 # Gear Up

	# Flaps at 15 deg (Landing)
	e_15deg = 0.7 
	ΔCD0_15deg_down = 0.055 # Gear Down
	ΔCD0_15deg_up =  0.03 # Gear Up
end

# ╔═╡ 883f5781-e694-441a-9d08-d3f2de47ee06
md"""### Climb 1: Takeoff Climb OEI
"""

# ╔═╡ e59d901b-4b72-4dc5-a8e5-996592216ffc
print(WF_Takeoff)

# ╔═╡ 2930785a-78ea-481d-a1db-d2dd3d25b70f
md"### Climb 2: Transition Climb OEI "

# ╔═╡ c1667ec4-142e-4d49-ad6b-88c8ef19d51b
md"### Climb 3: Second Climb OEI"

# ╔═╡ 9fc355f8-51ed-4d5e-af1e-79571afc76fb
md"### Climb 4: Enroute Climb OEI

The engine is at maximum continuous thrust here."

# ╔═╡ 88c8eb6a-34cf-4a9a-b67f-e8c5fda008de
md"#### Climb 5: Baulked Landing Climb OEI "

# ╔═╡ 02b2c8d3-e68d-4959-a32f-d99d31faf237
md"### Climb 6: Balked Landing Climb AEO 
"

# ╔═╡ ddb03780-ed64-4adf-9579-aebc3df5e649
md"""### Cruise

The thrust lapse of the engine with altitude is:

```math
T_\text{cruise} \approx \sigma^{0.6}_\text{cruise} T_0, \quad \sigma_\text{cruise} = 0.2846
```

Hence, evaluating the cruise ratios at the takeoff condition:

```math
\begin{align}
	\left(\frac{T}{W}\right)_\text{cruise} & = \frac{q C_{D_0}}{(W/S)} + \frac{K}{q}(W/S) \\
\implies \left(\frac{T_0}{W_0}\right)_\text{cruise} & = \frac{1}{\sigma^{0.6}_\text{cruise}}\left(\frac{W_\text{cruise}}{W_0}\right)\left(\frac{T}{W}\right)_\text{cruise}
\end{align}
```
The cruise weight fraction is calculated as follow:

 ```math
\frac{W_\text{cruise}}{W_0} = \frac{W_\text{cr}}{W_\text{cr-1}} \frac{W_\text{cr-1}}{W_\text{cr-2}}...\frac{W_1}{W_\text{0}}
```

"""

# ╔═╡ ef7ef832-679a-42b5-b0b2-350bc059f12f
cruise_condition(wing_loading, q, CD0, k) = q * CD0 / wing_loading + k / q * wing_loading

# ╔═╡ 9cda2c2a-0e00-4864-a62b-873826792191
md"
Assume $W_\text{cruise}/{W_0} \approx 0.92$."

# ╔═╡ 31e5f979-71f0-4fa0-b053-5dbea5330512
begin
	σ_cruise = 0.2846
	M_cruise = 0.76 			# Mach number
	a_FL360 = 295.37 			# Speed of sound at 36,000 ft
end

# ╔═╡ c8f0fed9-596a-4b31-bf0e-e0b3c27614dc
q = dynamic_pressure(σ_cruise * 1.225, M_cruise * a_FL360)

# ╔═╡ d64d5978-0d33-46c4-a99e-b1b6efa18724
k_cruise = induced_drag_coefficient(e_0deg, AR)

# ╔═╡ 32db9655-2181-4b22-b93a-40a13b556763
md"""### Constrained Optimization"""

# ╔═╡ 6c6fa635-8119-42e0-8081-704129f7a56a
md"""
# Fuselage Design
"""

# ╔═╡ ab4c7dfc-ae1b-4d31-8c0b-4ff1edcf1b57
md"#### Folding Table Sizing
In the business jet industry, the size of foldable tables holds significant importance. We recognize the need for spacious tables that can accommodate the demands of modern professionals. Our meticulously designed tables provide ample surface area to comfortably fit two 16-inch MacBook Pros each side of the table and A4 size document sidebyside, even when opened at a wide angle of 110 degrees. With our focus on practicality and productivity, we ensure that our tables meet the needs of discerning business travelers."


# ╔═╡ 1b87233d-db46-4bff-bbaf-8a40a0e6b709
begin
	MacBookPro_16_width  = 35.57 # From Apple Website 16-inch MacBookPro Tech Spec
	MacBookPro_16_Depth = 24.81 # From Apple Website 16-inch MacBookPro Tech Spec
	Screen_open_angle 	 = 110   # Best View at 110 open angle
	Open_depth 			 = cos((180-110)*(pi/180))* MacBookPro_16_Depth
	Minimum_Table_Depth  = 2*(Open_depth+MacBookPro_16_Depth) # in cm
	print( "The Folding Table Minimum Depth is ", Minimum_Table_Depth, "cm\r")
	A4_size_document_Width = 21
	Minimum_Table_Width  = MacBookPro_16_width + A4_size_document_Width # in cm
	print( "The Folding Table Minimum Width is ", Minimum_Table_Width, "cm")
	
end

# ╔═╡ abea4f86-9abc-4217-bbbd-d09d1b5c8601
html"""
<h5>Fuselage parameters</h5>

<img src="https://github.com/KulaiZeon/PaP2jHU1e9/blob/main/Fuselage%20des.png?raw=true"

>
"""

# ╔═╡ d3b42a56-6a67-4d2e-bbab-82a08e38dde8
begin
	Cabin_height = 1.8 #Average male height in U.S. is 1.77m, 1.8 maybe better
	Cabin_width = 1.8 #Diameter in meters, which should be the same as the height
	External_width = 1.8+0.0381*2 #Small commercial airplane: 1.5 inches (0.0381m*2)
	Fineness_ratio = 7 #by the picture above
	
	Fuselage_length = External_width*Fineness_ratio
	println("The length of the aircraft is:", Fuselage_length, " meters")
	
end

# ╔═╡ 7f5d9332-b3c4-4bdc-b51b-a0e92452069e
# ╠═╡ disabled = true
#=╠═╡
begin
	φ_s1 			= @bind φ1 Slider(0:1e-2:90, default = 15)
	ψ_s1 			= @bind ψ1 Slider(0:1e-2:90, default = 30)
	aero_flag 		= @bind aero CheckBox(default = true)
	stab_flag 		= @bind stab CheckBox(default = true)
	weights_flag 	= @bind weights CheckBox(default = false)
	strm_flag 		= @bind streams CheckBox(default = false)
end;
  ╠═╡ =#

# ╔═╡ acbe6151-c58e-4c1a-971e-48200927a4fa
md"""### Fuselage"""

# ╔═╡ 0caf1416-ffd8-4b24-be9b-28ef19622a8c
html"""
<h5>Cj4 measurement</h5>

<img src="https://github.com/KulaiZeon/PaP2jHU1e9/blob/main/cj4%20measure1.png?raw=true"

>
"""

# ╔═╡ ea5f4c42-1636-4cbc-be31-35d82c21bc22
# Fuselage definition
fuse = HyperEllipseFuselage(
    radius = External_width/2,          # Radius, m
    length = Fuselage_length,          # Length, m
    x_a    = 0.2,          # Start of cabin, ratio of length (nose to body) @7
    x_b    = 0.6,           # End of cabin, ratio of length(body to tail)1-@7-@8 around0.5
    c_nose = 1.6,            # Curvature of nose
    c_rear = 1.6,           # Curvature of rear
    d_nose = -(0.03/0.12)*External_width, # "Droop" or "rise" of nose,m @5/@2*radius
    d_rear = 0.040/0.12*External_width,  # "Droop" or "rise" of rear,m @6/@2*radius
    position = [0.,0.,0.]   # Set nose at origin, m (Centre line actually)
)

# ╔═╡ 88452ce5-fffd-4958-b628-09958d6d230d
begin
	ts = 0:0.01:1 # Distribution of each section for surface area and volume computation
	S_f = wetted_area(fuse, ts) # Surface area, m²
	V_f = volume(fuse, ts) # Volume, m³
	fuse_end_x = fuse.affine.translation.x + fuse.length # x-coordinate of fuselage end
end

# ╔═╡ 09470d80-35ac-4546-917f-bd40c02a1583
# ╠═╡ disabled = true
#=╠═╡
toggles = md"""
φ1: $(φ_s1)
ψ: $(ψ_s1)

Panels: $(aero_flag)
Weights: $(weights_flag)
Stability: $(stab_flag)
Streamlines: $(strm_flag)
"""
  ╠═╡ =#

# ╔═╡ 3920101e-f800-41da-b8c6-6d93f2256dfd
#=╠═╡
plt_vlm
  ╠═╡ =#

# ╔═╡ 30888073-67bf-4bdc-9e99-422a0823849a
fuse_end = fuse.affine.translation + [ fuse.length, 0., fuse.d_rear];

# ╔═╡ 15c94dac-9566-4b11-8d2b-19d107da910b
#=╠═╡
begin
	# Plot meshes
	plt_vlm = plot(
	    # aspect_ratio = 1,
	    xaxis = "x", yaxis = "y", zaxis = "z",
	    zlim = (-0.5, 0.5) .* span(wing_mesh),
	    camera = (φ1, ψ1),
	)

	# Surfaces
	if aero
		plot!(fuse, label = "Fuselage", alpha = 0.6)
		plot!(wing_mesh, label = "Wing", mac = false)
		plot!(htail_mesh, label = "Horizontal Tail", mac = false)
		plot!(vtail_mesh, label = "Vertical Tail", mac = false)
	else
		plot!(fuse, alpha = 0.3, label = "Fuselage")
		plot!(wing, 0.4, label = "Wing MAC 40%") 			 
		plot!(htail, 0.1, label = "Horizontal Tail MAC 40%") 
		plot!(vtail, 0.4, label = "Vertical Tail MAC 40%")
	end

	# CG
	#scatter!(Tuple(r_cg), label = "Center of Gravity (CG)")
	
	# Streamlines
	if streams
		plot!(sys, wing_mesh, 
			span = 4, # Number of points over each spanwise panel
			dist = 40., # Distance of streamlines
			num = 50, # Number of points along streamline
		)
	end

	# Weights
	if weights
		# Iterate over the dictionary
		[ scatter!(Tuple(pos), label = key) for (key, (W, pos)) in W_pos ]
	end

	# Stability
	if stab
		scatter!(Tuple(r_np), label = "Neutral Point (SM = $(round(SM; digits = 2))%)")
		# scatter!(Tuple(r_np_lat), label = "Lat. Neutral Point)")
		scatter!(Tuple(r_cp), label = "Center of Pressure")
	end
end
  ╠═╡ =#

# ╔═╡ 98bee0d1-c103-4c73-924d-29e960aa7107
md"""
# Wing Design
"""

# ╔═╡ 60743406-d883-4010-ad4a-add945bec32e
begin
	MTOW = MTOW_kg*9.81 
	Mass_Cruise = 0:500:8000 # kg
	Weight_Cruise = Mass_Cruise * 9.81
end

# ╔═╡ c4f8a09c-139c-49bb-8e53-109ed671aaef
CL_needed(Weight,cruise_rho,cruise_speed,WingArea) = (Weight*2)/(cruise_rho*cruise_speed^2*WingArea)

# ╔═╡ d766cb09-9fd0-4008-8bb5-2a2d9b7bddb1
md" 
## Geometric Information
"

# ╔═╡ a5772edc-854c-4b21-b370-bde1b34f3429
md"### Main Wing"

# ╔═╡ d1430272-9e20-4e5e-b531-740a450eed80
begin
	# AIRFOIL PROFILES
	foil_w_r = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=sc20518-il")) # Root (NASA SC(2)-0518 AIRFOIL (sc20518-il))
	foil_w_t = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=sc20414-il")) # Root (NASA SC(2)-0414 AIRFOIL (sc20414-il))
end

# ╔═╡ e7736066-1396-411f-8792-c3e1a01d4437
wing = WingSection(
	root_foil 	= foil_w_r,	    # Root airfoil
	tip_foil 	= foil_w_t, 	# Tip airfoil
	dihedral 	= 5., 			# Dihedral angle (deg)
	root_twist 	= 2., 			# Root twist angle (deg)
	tip_twist 	= -2., 			# Root twist angle (deg)
	area 		= Rjet_WingArea, 		# Wing area (m^2)
	aspect 		= Rjet_AR, 		# Aspect ratio
	
	sweep 		= 25., 				# Sweep angle (deg)
	w_sweep 	= 0.25, 			# Sweep angle location (c/4 sweep)
	taper 		= 0.35, 	        # Taper ratio (暫時冇用)
	
	symmetry 	= true, 			# symmetry
	position 	= [0.3fuse.length,0.,-0.5] 		# Position
)

# ╔═╡ 6b425df7-6c44-4dc8-be2e-290070769317
begin
	AR_w = aspect_ratio(wing) # AR of main wing
	S_w = projected_area(wing) # Reference wing area (m^2)
	lambda_w = deg2rad(sweeps(wing, 0.)[1]) # Leading-edge sweep angle, rad
	b_w = span(wing) # Span length, m
	c_w = mean_aerodynamic_chord(wing) # Mean aerodynamic chord, m
	mac40_wing = mean_aerodynamic_center(wing, 0.4) # Mean aerodynamic center (40%), m
	mac_w = mean_aerodynamic_center(wing, 0.25) # Mean aerodynamic center (25%), m
end

# ╔═╡ a0bdb17c-bc1e-4bc0-95b4-8b62369050ad
CL_cruise = CL_needed.(Weight_Cruise, 0.4135, 224.5,S_w) 

# ╔═╡ 3661c200-20a8-433b-bc5d-b4b154dc387c
plot(
	Weight_Cruise, # x-values (weights)
	CL_cruise, # y-values (CL required) 
	xlabel = "Weight of aircraft (N)", 
	ylabel = "CL required", 
	label = ""
)

# ╔═╡ cc6b6b53-5627-411d-8347-32b3a037dd82
S_ref = b_w * c_w 

# ╔═╡ d12827b6-b106-437a-b230-d0c65dbba7f6
md"""
## Inviscid vs Viscous Analysis
"""

# ╔═╡ 4edc4225-4b7f-4c79-9429-428e731a40dc
# XFOIL analysis function
"""
	xfoil_analysis(af :: Foil, 	# Airfoil
		α, Re;   				# Operating conditions
		mach = 0.0 				# Mach number
		iter = 100, 			# Number of iterations
		ncrit = 9., 			# Critical amplification ratio for transition
	)

Run a viscous XFOIL analysis with a `Foil`, angle of attack ``α``, Reynolds number ``Re`` as necessary inputs. Returns the viscous ``(C_l, C_d, C_m, C_p)`` and inviscid aerodynamic coefficients ``(C_{l_i}, C_{m_i}, C_{p_i})``. Also includes the ``x``-coordinates for plotting the pressure coefficient ``C_p`` distribution, and a `conv` flag indicating that the analysis converged.

## Optional Arguments

`mach = 0.0`: Mach number for compressible flow analysis via Prandtl-Glauert correction. Results may be incorrect if enabled, especially at Mach numbers close to transonic flow (``M ≈ 0.7``)

`iter = 100`: Number of iterations for the analysis. In some cases, you may receive a warning that the analysis has not converged. If so, increase this number and it might converge.

`ncrit = 9.`: This modifies the amplification ratio for the transition from laminar to turbulent flow. If it's set lower (usually in very noisy and turbulent wind conditions), then the airfoil will transition to turbulent flow closer to the leading edge along the surface.
"""
function xfoil_analysis(af :: Foil, alph, Re; mach = 0.0, iter = 100, ncrit = 9.)
	set_coordinates(af.x, af.y) # Import coordinates into XFOIL
	pane() 						# Refine the geometry for accuracy

	# Run inviscid analysis
	res_i = solve_alpha(alph; mach = M)  # Angle of attack, Mach number
	xs_i, Cp_x_i = Xfoil.cpdump() 	# Collect inviscid pressure distribution
	
	# Run viscous analysis
	res = solve_alpha(
		alph, 					# Angle of attack
		Re; 					# Reynolds number
		mach = mach,  			# Mach number
		iter = iter,  			# Max. number of iterations for solver
		# xtrip = xtrip  		# Manually set boundary layer transition location
	) 							# (e.g. accounting for dirt on the surface)

	if !res[5] @warn "Viscous analysis did not converge!" end

	xs, Cp_x = Xfoil.cpdump() 	# Collect viscous pressure distribution

	# Collect results and create NamedTuples
	res_i = (Cl_i = res_i[1], Cm_i = res_i[2], Cp_i = Cp_x_i, x = xs_i) # Inviscid
	
	res_v = (Cl = res[1], Cd = res[2], Cdp = res[3], Cm = res[4], conv = res[5], Cp = Cp_x, x = xs) # Viscous
	
	return res_v, res_i # Return results
end

# ╔═╡ 570b4126-0d8a-4603-ac15-b47dd31840da
af = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=sc20518-il")) # (NASA SC(2)-0518 AIRFOIL (sc20518-il))

# ╔═╡ 831b1d45-feac-415d-bbb3-c3ef4eef6f09
begin
	alph = 1.0 	# Angle (deg)
	M_inviscid    = 0.0 	# Mach number
	Re   = 9.96e6 	# Reynolds number
end

# ╔═╡ 562b03e6-750d-4bd2-9c7f-c87a5dc2c44e
visres, invres = xfoil_analysis(af, alph, Re; mach = M_inviscid, iter = 100); # Run XFOIL analysis

# ╔═╡ f1aede87-bab1-4d42-8489-15c89b7b2a37
invres # Inviscid (no drag)

# ╔═╡ 86ecb3b2-5b8a-4f44-8eec-e2588a929dbd
visres # Viscous

# ╔═╡ 588dc9dd-0a56-40c4-bdea-6a1844732463
visres.Cl / visres.Cd

# ╔═╡ cdc15a1a-1c26-4e7a-9805-224b215d8a2f
begin
	p1 = plot(af, lc = :red, aspect_ratio = 1, xlabel = "(x/c)") # Coordinates (flipping y-signs)
	p2 = plot(xlabel = "(x/c)", ylabel = "Cₚ", yflip = true) # Cp plot
	
	plot!(invres.x, invres.Cp_i, ls = :dash, lc = :grey, label = "Inviscid")
	plot!(visres.x, visres.Cp, lc = :red, label = "Viscous")

	plt_visc = plot(p1, p2, layout = (1,2), size = (800, 400))
end

# ╔═╡ eb936afd-9a4d-45af-818f-421e22545bcc
md"""
## Airfoil Comparison
"""

# ╔═╡ 5b754e48-cfe3-4c27-afec-75911337ee92
af_a = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=sc20518-il")) # SC(2)-0518 Airfoil

# ╔═╡ 90bde345-2ea6-40e7-b080-0e2ee95f2e2c
af_b = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=sc20414-il")) # (NASA SC(2)-0414 AIRFOIL (sc20414-il))

# ╔═╡ 578f09ae-c98f-4cfe-b9fa-57c210eebd2e
af_c = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=naca4412-il")) # NACA 4412 Airfoil

# ╔═╡ 98819907-a0a6-439b-bfee-0d82d0187e0c
begin
	alph2 = 3
	M2_inviscid = 0.0
	Re2 = 9.96e6
end

# ╔═╡ 10bab11b-8772-4f63-ac39-5e2d7ee15fbe
visres_a, invres_a = xfoil_analysis(af_a, alph2, Re2; mach = M2_inviscid); # Airfoil A

# ╔═╡ 2743c42c-249d-4b70-b7cb-02e371a79c0a
visres_b, invres_b = xfoil_analysis(af_b, alph2, Re2; mach = M2_inviscid); # Airfoil B

# ╔═╡ 6cc59cae-2e12-4bf4-8e2d-751f0d47eab0
visres_c, invres_c = xfoil_analysis(af_c, alph2, Re2; mach = M2_inviscid); # Airfoil C

# ╔═╡ d5f23980-84d1-4308-bdc8-3ad685e330cf
visres_a # Airfoil A

# ╔═╡ 3433a47f-bb2e-42e0-a258-dca84453f63b
visres_b # Airfoil B

# ╔═╡ 83cc69e5-adb0-4beb-b515-8fd662d073d5
visres_c # Airfoil C

# ╔═╡ 22aa49ea-ee11-493b-9a15-266785bf48ed
visres_a.Cl / visres_a.Cd # Airfoil A

# ╔═╡ 2b980c26-6429-467b-b57f-19c785c3f19b
visres_b.Cl / visres_b.Cd # Airfoil B

# ╔═╡ ab8d469d-ce31-48a2-b3c6-96393b950381
visres_c.Cl / visres_c.Cd # Airfoil C

# ╔═╡ 2711abe2-b740-4871-890e-e3c1d0bc1dfc
begin 
	# Airfoil coordinates
	plt_foils = plot(aspect_ratio = 1)
	plot!(af_a) # Airfoil A
	plot!(af_b, color=:red) # Airfoil B
	plot!(af_c, color=:black) # Airfoil C
	plot!(xlabel = "(x/c)")

	# Pressure coefficient distribution
	plt_Cp = plot(xlabel = "(x/c)", ylabel = "Cₚ", yflip = true)
	plot!(visres_a.x, visres_a.Cp, label = "$(af_a.name)") # Viscous Cp
	plot!(visres_b.x, visres_b.Cp, label = "$(af_b.name)", color=:red)
	plot!(visres_c.x, visres_c.Cp, label = "$(af_c.name)", color=:black)

	plot!(legend = false)

	# Combine plots
	plt_compare = plot(plt_foils, plt_Cp, layout = (1,2), size = (800, 400))
end

# ╔═╡ 56926f5f-32fc-4798-aa95-0a78fe126eb6
begin
function lift_curve(airfoil,start_angle,end_angle)
	angles = start_angle:1:end_angle
    results1 = []

	

    for angle in angles
        # Perform computations or call your function with the current angle
        result1,result2 = xfoil_analysis(airfoil, angle, 1e6; mach = M_inviscid, iter = 100)
        push!(results1, result1.Cl)
    end
   return results1

end

end

# ╔═╡ 3a50f23f-d5fc-49e0-a5c0-ab52b098ff02
angles = -20:1:20

# ╔═╡ 7e1321a2-b197-4c60-a6fc-03e533a5504c
begin 
	plt_Cl = plot(xlabel = "(AOA)", ylabel = "CL")
	plot!(angles, lift_curve(af_a,-20, 20), label = "$(af_a.name)", color=:red)
	plot!(angles, lift_curve(af_b,-20, 20), label = "$(af_b.name)", color=:black)

	plot!(legend = true)

end

# ╔═╡ ba2f2e00-aa5f-4478-9951-c7a16a3834f7
begin
function drag_curve(airfoil,start_angle,end_angle)
	angles = start_angle:1:end_angle
    results2 = []

	

    for angle in angles
        # Perform computations or call your function with the current angle
        result1,result2 = xfoil_analysis(airfoil, angle, 1e6; mach = M_inviscid, iter = 100)
        push!(results2, result1.Cd)
    end
   return results2

end

end

# ╔═╡ 7e453270-1320-458d-a1e7-921d86d0e750
begin 
	plt_Cd = plot(xlabel = "(AOA)", ylabel = "Cd")
	plot!(angles, drag_curve(af_a,-20, 20), label = "$(af_a.name)", color=:red)
	plot!(angles, drag_curve(af_b,-20, 20), label = "$(af_b.name)", color=:black)
	plot!(legend = false)

end

# ╔═╡ 4cbf0b7e-7886-41b2-bc62-f54f601fa9f1
minimum(drag_curve(af_a,-20, 20))

# ╔═╡ 0fe19e3b-36a8-4d17-b89b-c04419c7fbe6
begin 
	plt_ClCd = plot(xlabel = "(Cd)", ylabel = "Cl")
	plot!(drag_curve(af_a,-20, 20), lift_curve(af_a,-20, 20), label = "$(af_a.name)", color=:red)
	plot!(drag_curve(af_b,-20, 20), lift_curve(af_b,-20, 20), label = "$(af_b.name)", color=:black)

	plot!(legend = false)

end

# ╔═╡ 8774bd8f-91eb-4c86-9ba9-62fae14188f9
begin
	minimum( drag_curve(af_a,-20, 20))
	idx = findfirst( drag_curve(af_a,-20, 20).==minimum( drag_curve(af_a,-20, 20)))
	given_y = lift_curve(af_a,-20, 20)[idx]
	Cl_min_drag = given_y
end

# ╔═╡ c83b9044-c5cf-4308-a3a1-4502c11385e0
begin 
	CD_min = minimum(drag_curve(af_a,-20, 20))
	CL_min_drag = Cl_min_drag 
	k = induced_drag_coefficient(e_0deg, Rjet_AR)
	cds = drag_polar.(CD_min, k, cls, CL_min_drag)

	CD_min_2 = CD_min+ 0.035 
	k_2 = induced_drag_coefficient(e_5deg, Rjet_AR)
	cds_2 = drag_polar.(CD_min_2, k_2, cls, CL_min_drag)

	CD_min_3 = CD_min + 0.01
	k_3 = induced_drag_coefficient(e_5deg, Rjet_AR)
	cds_3 = drag_polar.(CD_min_3, k_3, cls, CL_min_drag)

	CD_min_4 = CD_min + 0.045
	k_4 = induced_drag_coefficient(e_10deg, Rjet_AR)
	cds_4 = drag_polar.(CD_min_4, k_4, cls, CL_min_drag)

	CD_min_5 = CD_min + 0.02
	k_5 = induced_drag_coefficient(e_10deg, Rjet_AR)
	cds_5 = drag_polar.(CD_min_5, k_5, cls, CL_min_drag)

	CD_min_6 = CD_min +0.055
	k_6 = induced_drag_coefficient(e_15deg, Rjet_AR)
	cds_6 = drag_polar.(CD_min_6, k_6, cls, CL_min_drag)

	CD_min_7 = CD_min +0.03
	k_7 = induced_drag_coefficient(e_15deg, Rjet_AR)
	cds_7 = drag_polar.(CD_min_7, k_7, cls, CL_min_drag)
end;

# ╔═╡ f27aba2f-10d2-4cc5-b86d-228abbb61cc0
begin
	CD0 = CD_min - k*(CL_min_drag)^2
	println("The value of CD0 is ", CD0)
end

# ╔═╡ e66b3643-b2db-4bf5-868b-7ea1832efa29
tbw_cruise = 1/σ_cruise^0.6 * WF_LongRangeCruise * cruise_condition.(wing_loadings, q, CD0, k_cruise);

# ╔═╡ 61ab67ec-85da-482b-95f7-14d94a4a7b74
print(tbw_cruise)

# ╔═╡ 5520b2f9-cbdd-46ef-8200-76828bee4661
begin
	plot(cds, cls, 
		 label = "CDₘᵢₙ = $CD_min, CL (min drag) = $CL_min_drag",
		 xlabel = "CD", ylabel = "CL", title = "Drag Polar")
	plot!(cds_2, cls, 
		  label = "CDₘᵢₙ = $CD_min_2, CL (min drag) = $CL_min_drag")
	plot!(cds_3, cls, 
		  label = "CDₘᵢₙ = $CD_min_3, CL (min drag) = $CL_min_drag")
	plot!(cds_4, cls, 
		  label = "CDₘᵢₙ = $CD_min_4, CL (min drag) = $CL_min_drag")
	plot!(cds_5, cls, 
		  label = "CDₘᵢₙ = $CD_min_5, CL (min drag) = $CL_min_drag")
	plot!(cds_6, cls, 
		  label = "CDₘᵢₙ = $CD_min_6, CL (min drag) = $CL_min_drag")
	plot!(cds_7, cls, 
		  label = "CDₘᵢₙ = $CD_min_7, CL (min drag) = $CL_min_drag")
end

# ╔═╡ 1bea727e-8b43-4c50-a38c-805770100fc3
begin	
	k_s_takeoff  = 1.2
	G_takeoff 	 = 0.012
	ΔCD0_takeoff = ΔCD0_5deg_down # Flaps 5 deg, gear down
	k_takeoff 	 = induced_drag_coefficient(e_5deg, AR)
	WF_takeoff_climb = 0.99 * WF_Takeoff # Takeoff climb weight fraction (don't know why need to mutiplied by 0.99)
	
	TbW_takeoff_climb = thrust_corrected_climb(k_s_takeoff, CD_min + ΔCD0_takeoff, CL_max_climb, k_takeoff, G_takeoff, n_eng, WF_takeoff_climb, OEI = true)
	
	takeoff_climbs = fill(TbW_takeoff_climb, length(wing_loadings))
end

# ╔═╡ f1552f2d-8f0c-4065-9f47-e5349cbe25ca
begin	
	k_s_trans 	= 1.2
	G_trans 	= 0
	ΔCD0_trans 	= ΔCD0_5deg_down # Flaps 5 deg, gear down
	k_climb 	= induced_drag_coefficient(e_5deg, AR)
	WF_trans 	= 0.99 * WF_Climb1 # Weight fraction at transition climb 
	
	TbW_trans_climb = thrust_corrected_climb(k_s_trans, CD_min + ΔCD0_trans, CL_max_climb, k_climb, G_trans, n_eng, WF_trans, OEI = true)
	
	trans_climb = fill(TbW_trans_climb, length(wing_loadings))
end

# ╔═╡ 47be4dfd-bc90-4711-966f-c20aa3c6f2a8
begin	
	k_s_second 	= 1.2
	G_second 	= 0.024
	ΔCD0_second = ΔCD0_5deg_up # Flaps 5 deg, gear up
	k_second 	= induced_drag_coefficient(e_5deg, AR)
	WF_second   = 0.98 * WF_trans # Weight fraction at second climb

	TbW_second_climb = thrust_corrected_climb(k_s_second, CD_min + ΔCD0_second, CL_max_climb, k_second, G_second, n_eng, WF_second, OEI = true)
	
	second_climb = fill(TbW_second_climb, length(wing_loadings))
end;

# ╔═╡ 4041daef-d131-4778-aebc-ee8608dcdc68
begin	
	k_s_enroute  = 1.25
	G_enroute 	 = 0.012
	ΔCD0_enroute = ΔCD0_0deg_up # Clean, i.e. no flaps, gear up
	k_enroute 	 = induced_drag_coefficient(e_0deg, AR)
	WF_enroute 	 = 0.98 * WF_second # Weight fraction at enroute climb

	TbW_enroute_climb = thrust_corrected_climb(k_s_enroute, CD_min + ΔCD0_enroute, CL_max_climb, k_enroute, G_enroute, n_eng, WF_enroute, MCT = true, OEI = true)
	
	enroute_climb = fill(TbW_enroute_climb, length(wing_loadings))
end;

# ╔═╡ e4e6425d-bf3c-4bf2-948a-ecc7aa82c1eb
begin	
	k_s_baulked_OEI = 1.5
	G_baulked_OEI = 0.021
	ΔCD0_baulked_OEI = ΔCD0_10deg_down # Flaps 10 deg, gear up
	k_baulked_OEI = induced_drag_coefficient(e_10deg, AR)
	WF_baulked_OEI = WF_Landing # Maximum landing weight fraction

	TbW_baulked_OEI = thrust_corrected_climb(k_s_enroute, CD_min + ΔCD0_baulked_OEI, CL_max_climb, k_baulked_OEI, G_baulked_OEI, n_eng, WF_baulked_OEI, OEI = true)
	
	baulked_OEI_climb = fill(TbW_baulked_OEI, length(wing_loadings))
end;

# ╔═╡ e637be1f-413d-4d5f-9893-509c715cd775
begin	
	k_s_baulked_AEO  = 1.3
	G_baulked_AEO    = 0.032
	ΔCD0_baulked_AEO = ΔCD0_15deg_down# Flaps 15 deg, gear up
	k_baulked_AEO    = induced_drag_coefficient(e_15deg, AR)
	WF_baulked_AEO   = WF_Landing # NEED TO CHECK

	TbW_baulked_AEO = thrust_corrected_climb(k_s_enroute, CD_min + ΔCD0_baulked_AEO, CL_max_climb, k_baulked_AEO, G_baulked_AEO, n_eng, WF_baulked_AEO)
	
	baulked_AEO_climb = fill(TbW_baulked_AEO, length(wing_loadings))
end;

# ╔═╡ f132d897-962e-4f48-83dc-009e85a003bf
begin 
	plot(xlabel = "W/S, N/m²", ylabel = "T/W", title = "Matching Chart", legend = :outertopright)
	plot!(stalls_2_0, TbWs, label = "Stall CLmax2.0")
	plot!(stalls_2_2, TbWs, label = "Stall CLmax2.2")
	plot!(stalls_2_4, TbWs, label = "Stall CLmax2.4")
	plot!(stalls_2_6, TbWs, label = "Stall CLmax2.6")
	plot!(wing_loadings, TbW_takeoff_1_6, label = "Takeoff CLmaxTO 1.6")
	plot!(wing_loadings, TbW_takeoff_1_7, label = "Takeoff CLmaxTO 1.7")
	plot!(wing_loadings, TbW_takeoff_1_8, label = "Takeoff CLmaxTO 1.8")
	plot!(wing_loadings, TbW_takeoff_1_9, label = "Takeoff CLmaxTO 1.9")
	plot!(wing_loadings, TbW_takeoff_2_0, label = "Takeoff CLmaxTO 2.0")
	plot!(wing_loadings, TbW_takeoff_2_1, label = "Takeoff CLmaxTO 2.1")
	plot!(wing_loadings, TbW_takeoff_2_2, label = "Takeoff CLmaxTO 2.2")
	plot!(wbs_landing, TbWs, label = "Landing")
	plot!(wing_loadings, takeoff_climbs, label = "Climb 1")
	plot!(wing_loadings, trans_climb, label = "Climb 2")
	plot!(wing_loadings, second_climb, label = "Climb 3")
	plot!(wing_loadings, enroute_climb, label = "Climb 4")
	plot!(wing_loadings, baulked_AEO_climb, label = "Climb 5")
	plot!(wing_loadings, baulked_OEI_climb, label = "Climb 6")
	annotate!(1250, 0.2, "Feasible")
	annotate!(4000, 0.1, "Infeasible")
end

# ╔═╡ 8386b75b-090c-4ceb-8d7d-e92cab8461fc
begin
	plot(
		xlabel = "(W/S), N/m²", 
		ylabel = "(T/W)", 
		title = "Matching Chart",
		legend = :bottomright
		
	)
	# Lines
	plot!(stalls_2_0, TbWs, label = "Stall CLmax2.0")
	plot!(stalls_2_2, TbWs, label = "Stall CLmax2.2")
	plot!(stalls_2_4, TbWs, label = "Stall CLmax2.4")
	plot!(stalls_2_6, TbWs, label = "Stall CLmax2.6")
	plot!(wing_loadings, TbW_takeoff_1_6, label = "Takeoff CLmaxTO 1.6")
	plot!(wing_loadings, TbW_takeoff_1_7, label = "Takeoff CLmaxTO 1.7")
	plot!(wing_loadings, TbW_takeoff_1_8, label = "Takeoff CLmaxTO 1.8")
	plot!(wing_loadings, TbW_takeoff_1_9, label = "Takeoff CLmaxTO 1.9")
	plot!(wing_loadings, TbW_takeoff_2_0, label = "Takeoff CLmaxTO 2.0")
	plot!(wing_loadings, TbW_takeoff_2_1, label = "Takeoff CLmaxTO 2.1")
	plot!(wing_loadings, TbW_takeoff_2_2, label = "Takeoff CLmaxTO 2.2")
	plot!(wbs_landing, TbWs, label = "Landing")
	plot!(wing_loadings, takeoff_climbs, label = "Climb 1")
	plot!(wing_loadings, trans_climb, label = "Climb 2")
	plot!(wing_loadings, second_climb, label = "Climb 3")
	plot!(wing_loadings, enroute_climb, label = "Climb 4")
	plot!(wing_loadings, baulked_AEO_climb, label = "Climb 5")
	plot!(wing_loadings, baulked_OEI_climb, label = "Climb 6")
	plot!(wing_loadings, tbw_cruise, label = "Cruise")
	
	
	ylims!(0,0.6)
	# Annotation
	annotate!(1750, 0.40, "Feasible")

	
	
	# Points
	scatter!([6480], [TbW_takeoff_climb], label = "Constrained Optimum 1 (Min Thrust)") # Plot min thrust point evaluated graphically
	scatter!([stalls_2_0], [0.271], label = "Constrained Optimum 2 (Max Wing Loading)")
	 # Plot max wing loading point evaluated graphically
	scatter!([2258],[0.203])

	#Competitor
	scatter!([2258.95],[0.406], label= "Cessna CJ3 G2")
	scatter!([2483.22],[0.423], label= "Cessna CJ4 G2")
	scatter!([3196.90],[0.460], label= "Beechjet 400A")
	scatter!([2805.32],[0.374], label= "Embraer Phenom 300")
	scatter!([3304.56],[0.358], label= "Learjet 75")
	scatter!([3564.37],[0.357], label= "Bombardier Challenger 300* (A much larger business jet)")
	scatter!([3949.02],[0.339], label= "Gulfstream G150* (A much larger business jet)")

end

# ╔═╡ 39c0bba6-cd04-483a-baca-e4c975db261a


# ╔═╡ 544df64c-bef7-4125-9b50-4937589832c2
md"""
### Tail Volume coefficients
"""

# ╔═╡ 82b62e79-60de-4829-890b-dc9e6a0d018c
begin
	md"""
	Tail Volume = tail surface area x moment arms
	"""
	#Length between tail MAC and wing MAC, aka Tail moment arms, aft-mounted engines:
	L_vt = (0.5 * Fuselage_length) + 6.09
	L_ht = (0.5 * Fuselage_length) + 6.09
	
	### c_vt and c_ht values factored in 95% of T-tail effects
	
	c_vt = 0.95*0.09 #Typical tail volume coefficients = 0.09
	c_ht = 0.95*1.00 #Typical tail volume coefficients = 1.00
	
	S_vt = (c_vt*b_w*S_w)/L_vt 
	S_ht=(c_ht*c_w*S_w)/L_ht 

	println("The expected area of vertical tail: ", S_vt, " meters squared")
	println("The expected area of horizontal tail: ", S_ht, " meters squared")
	
end

# ╔═╡ a7f9e034-79c6-4a00-a3ba-502b3687ed00
md"### Horizontal Stabilizer"

# ╔═╡ b9062352-3b94-44e3-8f13-d6ad9e6c22c7
con_foil = control_surface(naca4(0,0,1,2), hinge = 0.75, angle = -10.)

# ╔═╡ 1588ec8c-9040-4873-81b1-92cbd0ab9f09
htail = WingSection(
    area        = S_ht,  			# Area (m²). HOW DO YOU DETERMINE THIS?
    aspect      = 5,  			# Aspect ratio
    taper       = 0.4,  			# Taper ratio
    dihedral    = 7.,   			# Dihedral angle (deg)
    sweep       = 35.,  			# Sweep angle (deg)
    w_sweep     = 0.,   			# Leading-edge sweep
    root_foil   = con_foil, 	# Root airfoil
	tip_foil    = con_foil, 	# Tip airfoil
    symmetry    = true,

    # Orientation
    angle       = 5,  # Incidence angle (deg). HOW DO YOU DETERMINE THIS?
    axis        = [0., 1., 0.], # Axis of rotation, y-axis
    position    = fuse_end - [ 3., 0., 0.15], # HOW DO YOU DETERMINE THIS?
)

# ╔═╡ 6fcfc773-0a43-45a8-b777-ea0e542ff015
begin
	AR_h 		= aspect_ratio(htail)
	S_h 		= projected_area(htail)
	lambda_h 	= deg2rad(sweeps(htail)[1])
	mac25_h 	= mean_aerodynamic_center(htail, 0.25)
	mac40_h 	= mean_aerodynamic_center(htail, 0.4)
end

# ╔═╡ 50773fa5-b0c2-430b-9c13-3031bcda5d52
md"### Vertical Stabilizer"

# ╔═╡ fee8e83b-2670-4887-832c-c7f00fde522e
vtail = WingSection(
    area        = S_vt, 			# Area (m²). # HOW DO YOU DETERMINE THIS?
    aspect      = 1.2,  			# Aspect ratio
    taper       = 0.7,  			# Taper ratio
    sweep       = 40.0, 			# Sweep angle (deg)
    w_sweep     = 0.,   			# Leading-edge sweep
    root_foil   = naca4(0,0,0,9), 	# Root airfoil
	tip_foil    = naca4(0,0,0,9), 	# Tip airfoil

    # Orientation
    angle       = 90.,       # To make it vertical
    axis        = [1, 0, 0], # Axis of rotation, x-axis
    position    = htail.affine.translation - [0.,0.,-0.5] # HOW DO YOU DETERMINE THIS?
) # Not a symmetric surface

# ╔═╡ 88c42c90-0bc5-4c2b-aaff-31b8160d89c1
chords(vtail)

# ╔═╡ 95b77ea6-3fa9-4735-b909-20d50509db32
b_v = span(vtail)

# ╔═╡ 5d767246-ca69-4318-b334-67065b719f83
# ╠═╡ disabled = true
#=╠═╡
S_v = projected_area(vtail)
  ╠═╡ =#

# ╔═╡ c2b76ab7-121b-4020-8d44-854769835f5e
c_v = mean_aerodynamic_chord(vtail)

# ╔═╡ 00893fb7-6538-45d8-a439-79cc4bbcf939
mac_v = mean_aerodynamic_center(vtail)

# ╔═╡ 19336d97-8355-4dc5-815d-ae149886dec1
begin
	S_v = projected_area(vtail)
	mac25_v = mean_aerodynamic_center(vtail, 0.25)
	mac40_v = mean_aerodynamic_center(vtail, 0.4)
end

# ╔═╡ f97bf075-4109-4ad2-93a1-238707fba1e6
V_v = S_v / S_w * (mac_v.x - mac_w.x) / b_w

# ╔═╡ e905c082-b8ee-4fbb-8430-5b23cc66cd0f
mac_v.x

# ╔═╡ 2d3f7c94-da57-4a30-a6a8-74f720ecfa79
md"""
	### Verifying OEI condition with Vertical Tail
	"""

# ╔═╡ cbc899eb-8280-4e2d-bec3-6db70449850b
md"""
Since the yawing moment from rudder is larger than the critical yawing moment, the sizing of vertical stabilizer is appropriate.
"""

# ╔═╡ 55dfb095-9059-438d-a7ba-4feed9985bfd
md"
## Visualization
"

# ╔═╡ 92d751f8-1760-4163-aad1-f7ba638522a3
# ╠═╡ disabled = true
#=╠═╡
name = "RJet Wing"
  ╠═╡ =#

# ╔═╡ 95827391-53cb-4583-9b68-93db854e7596
sliders=begin
	ϕ_s = @bind ϕ Slider(0:90, default = 30)
	φ_s = @bind φ Slider(0:90, default = 30)

	ϕ_s, φ_s
end

# ╔═╡ 0f849781-eead-468c-af84-8488c02d14e9
md"""
## Aerodynamics Analysis
"""

# ╔═╡ 0cfa4648-5d17-45ab-a77a-9233831562d5
md"
### Meshing 
"

# ╔═╡ a1e6baf2-6bf6-40cd-b315-ecc4dc42b7a7
wing_mesh = WingMesh(
	wing, 		# Wing type
	[20], 		# Number of spanwise panels as a vector (not sure how it affect !!it shows how detail the flow simulation runs by Sunny, )
	12, # Number of chordwise panels as an integer
)

# ╔═╡ 158315ef-c783-4cf0-b551-9eac22775768
htail_mesh = WingMesh(htail, [10], 8);

# ╔═╡ 9ccb66fd-8b49-4c01-8e8c-09688030443a
vtail_mesh = WingMesh(vtail, [8], 6);

# ╔═╡ ea2ac373-e1c9-420f-9dfa-4c25b7724fa4
S_wet = wetted_area(wing_mesh) # wetted area 

# ╔═╡ 68868d79-2553-4a0f-99d2-876662adb8fe
S_wet_ratio = wetted_area_ratio(wing_mesh)

# ╔═╡ 93ae7550-2df0-425b-8e5e-f1cf98e48565
C_d_min = 0.0045*S_wet_ratio

# ╔═╡ f3da7627-c3db-4dd6-a650-907ad41e49a8
md"
### Vortex Lattice Method
"

# ╔═╡ b68dfdee-39fd-49cc-8285-6dcd3598c665
md"For the analysis, we need to generate a Horseshoe type, corresponding to horseshoe singularity elements used in the vortex lattice method. This is generated as follows:"

# ╔═╡ fc26e8aa-1aaa-4398-bbbd-49aaf45112a2
aircraft = ComponentVector(
	wing = make_horseshoes(wing_mesh),
	htail = make_horseshoes(htail_mesh),
	vtail = make_horseshoes(vtail_mesh)
)

# ╔═╡ dbded2be-5917-4646-ac71-66cb8726a196
md"#### Freestream condition"

# ╔═╡ d7ed25a8-5170-4b30-8927-4148a5f40563
fs = Freestream.( 
	alpha = 3, # angle of attack (degree)
	beta = 0.0,  # sideslip angle (degree)
	omega = [0.0, 0.0, 0.0] # rotation vector 
);

# ╔═╡ 7915c507-408c-4854-aee3-b38ff9b48ef5
refs = References(
	speed = V_C1_W, # reference speed ()
	area = projected_area(wing),
	span = span(wing),
	chord = mean_aerodynamic_chord(wing),
	density = σ_cruise*1.225,
	location = mean_aerodynamic_center(wing)
);

# ╔═╡ 6e3f6750-31f1-41f9-9b3e-4d045b62e61f
system = solve_case(
	aircraft, fs, refs,
	compressible = true, # Compressibility option
	print = false, # Print the results for only the aircraft      
	print_components = true #Prints the results for all components
);

# ╔═╡ 65a228ad-9fc9-4417-ace2-38c9a7534e85
md"#### Nearfield"

# ╔═╡ 4e380d8f-d337-4d4a-806e-b26a9bbd08af
nfs = nearfield(system)

# ╔═╡ 9fc0c9db-71fb-48c2-897b-386ecaa21db9
nfs.CX # Induced drag coefficient (nearfield)

# ╔═╡ 239ec23b-7b81-4c0a-a5c4-95264514d552
nfs.CZ # Lift coefficient (nearfield)

# ╔═╡ 2be842b9-70c9-4310-9f98-468a23adeaa9
nfs.Cm # Pitching moment coefficient

# ╔═╡ 54373f51-4cb7-4f07-890e-9b36cf348f96
md"#### Farfield"

# ╔═╡ 20320a6b-1c77-4640-ab62-c58aa7df89a2
ffs = farfield(system) # Farfield coefficients (no moment coefficients)

# ╔═╡ 7e4c5eeb-b2bc-450b-a3f6-f031395083c8
ffs.CDi # Induced drag coefficient (farfield)

# ╔═╡ 56aeab99-9c7a-4f46-b20e-635e8389c79c
ffs.CL # Lift coefficient (farfield)

# ╔═╡ 76b1f18b-0269-4ac9-b6d2-9ac2314bb31e
ffs.CL / ffs.CDi # Lift-to-induced drag ratio

# ╔═╡ 3d2dedeb-919b-4dba-97c6-ca24210e4f4d
function vary_alpha(aircraft, α, refs)
	
	fs = Freestream(alpha = α)
	
	system = solve_case(
		aircraft, fs, refs;
	    compressible = true, # Compressibility option
	)
	return system
end

# ╔═╡ d39b06d3-5837-4fd5-90d1-5da8bc028a6c
begin
	alphas = -10:0.5:10 # range of angle of attack
    systems = [vary_alpha(aircraft, alpha, refs) for alpha in alphas ]
	coeffs = [nearfield(sys) for sys in systems]
    CDis = [coeff.CX for coeff in coeffs]
    CLs = [coeff.CZ for coeff in coeffs]
	CFs, CMs = surface_coefficients(system) # Get coefficients over the surfaces in wind axes
end 

# ╔═╡ 6e7c6fc8-c946-4bdc-aa85-b73535441ef4
wing_loads = spanwise_loading(wing_mesh, refs, CFs.wing, system.circulations.wing)

# ╔═╡ 8177a2a7-a03e-4e23-af77-36ad0e73d7ba
function plot_wingload(wing_loads)
    plt_CD = plot(wing_loads[:,1], wing_loads[:,2], ylabel = "CDi", label = "")
    plt_CY = plot(wing_loads[:,1], wing_loads[:,3], ylabel = "CY", label = "")
    plt_CL = begin 
        plot(wing_loads[:,1], wing_loads[:,4], ylabel = "CL", label = "") # CL
        plot!(wing_loads[:,1], wing_loads[:,5], label = "CL_norm") # CL normalized
    end

    # Combine plots
    plot(plt_CD, plt_CY, plt_CL, layout = (3,1), xlabel = "y")
end

# ╔═╡ f23ca3f2-fbf0-4a5f-98cd-bd2f7b8ca6d1
plot_wingload(wing_loads)

# ╔═╡ fe43a1c3-37da-46cd-a34f-6e395332b2d8
function plot_aero(alphas, CLs, CDis)
    plot1 = plot(alphas, CLs, ylabel = "CL", xlabel = "α", label = "")

    plot2 = plot(CDis, CLs, label = "", xlabel = "CDi", ylabel = "CL", title  = "Drag Polar")
	
    plot(plot1, plot2, layout = (2, 1))  # 2行1列的布局
end


# ╔═╡ b6289530-910b-4635-995a-f9253fc7b9a3
plot_aero(alphas, CLs, CDis)

# ╔═╡ 3a52cfc6-9104-496c-b55d-27f61db86308
begin
	CL_alpha_equation = polyfit(alphas, CLs,1)
	CL_alpha = CL_alpha_equation(1)-CL_alpha_equation(0) 
end


# ╔═╡ 08b15d6c-c1bb-4e77-bb1a-2e69928166de
md" # Stability Analysis"

# ╔═╡ 2b04d627-6170-40e6-a39a-f4c5b8aad2bc
md"### Wing Design"

# ╔═╡ abf57e1b-4bf9-4afa-901c-1baa815f3053
begin
	plt_wing_airfoil = plot(foil_w_r, aspect_ratio = 1, xlims=(-0.1,1.3), label = "NASA SC(2)-0518 AIRFOIL (sc20518-il)")
	plot!(foil_w_t, aspect_ratio = 1, xlims=(-0.1,1.3), label = "NASA SC(2)-0414 AIRFOIL (sc20414-il)")
end 

# ╔═╡ 4ca39f31-e857-4760-948e-a4550a46110a
savefig(plt_wing_airfoil, "plots/2D_wing_airfoil.png")

# ╔═╡ c73de1e2-ce4e-4fe9-be5b-460f211535ed
sweeps(wing, 0.25)  # Quarter-chord sweep angles

# ╔═╡ 4626c7d2-e67a-48e9-b107-71e5479891f3
begin
	mac25_w = mean_aerodynamic_center(wing, 0.25)
	mac40_w = mean_aerodynamic_center(wing, 0.40) 
end

# ╔═╡ fe927eee-5ae9-4429-a05a-448d0240edfb
md" ### Engine placement"

# ╔═╡ d46f2f0d-1c2d-4383-9ca4-68d11ca0c305
wing_coo = coordinates(wing) # Get leading and trailing edge coordinates

# ╔═╡ 528848af-7f75-441a-8130-a5fa6335ef80
wing_coo[1,:] # Leading edge coordinates

# ╔═╡ 69f64482-05f9-43ed-980e-072dedad87b9
begin 
	eng_L = wing_coo[1,1] - [-1.7, -5, -0.307] # Left engine, at mid-section leading edge
	eng_R = wing_coo[1,3] - [-1.7, 5, -0.307] # Right engine, at mid-section leading edge
end

# ╔═╡ a65b3ab7-4acd-46bd-b4a1-3eaae53211ae
md"""### Static Margin Estimation

The weights of the components of the aircraft are some of the largest contributors to the longitudinal stability characteristics.

![](https://raw.githubusercontent.com/HKUST-OCTAD-LAB/MECH3620Materials/main/pics/777200LRMoments.svg)

In addition to the weights, the aerodynamic forces depicted are also major contributors to the stability of a conventional aircraft configuration.

![](https://raw.githubusercontent.com/HKUST-OCTAD-LAB/MECH3620Materials/main/pics/777200LR.svg)

This interrelationship between aerodynamics and weights on stability is expressed via the static margin.

```math
\text{Static Margin} = \frac{x_{cg} - x_{np}}{\bar c} 
```

We need to determine both of these locations: the center of gravity $x_{cg}$ and the neutral point $x_{np}$.
"""

# ╔═╡ 5f1c17cb-d7a9-413c-b41c-fee49956d945
md"
This interrelationship between aerodynamics and weights on stability is expressed via the static margin.

```math
\text{Static Margin} = \frac{x_{np} - x_{cg}}{\bar c} 
```

We need to determine both of these locations: the center of gravity $x_{cg}$ and the neutral point $x_{np}$.
"

# ╔═╡ e5b8d53d-f36f-4bd9-af04-9c8b9b7b28f0
md" ### Loading of Components"

# ╔═╡ 5b60d84a-070d-4a3f-89b0-edc48ef761b7
begin
	wing_loading = 12.				# kg/m^2
	htail_loading = 10. 			# kg/m^2
	vtail_loading = 10.				# kg/m^2
	fuse_loading = 7.				# kg/m^2
end;

# ╔═╡ 27157ae0-e1d6-480d-aa6b-058e5c9a219a
md"### Weight Ratios of Components"

# ╔═╡ 6013b000-5c56-48c4-8acc-c5308bbdb70e
begin
	WR_noseLG = 0.043*0.15 # 0.057 * 15 %
	WR_mainLG = 0.043*0.85 # 0.057 * 85 %
	WR_engine = 1.3
	WR_allelse = 0.1
end;

# ╔═╡ 6a3d6701-c780-47f4-89ca-d12e3f25f40a
begin
	TOGW = 7862.16 # Takeoff gross weight, kg (refer to inital est MTOW)
	W_engine = 298 # William FJ44-4A (single), kg
end

# ╔═╡ 3fad3b11-e860-4e73-979b-3f603a5e4874
md" ### Center of Gravity

The aircraft’s center of gravity (CG) is defined as:
```math
\mathbf{r}_\text{cg} = \frac{\sum_i W_i \ (\mathbf{r}_{\text{cg}})_i}{\sum_i W_i}, \quad \mathbf{r} = \begin{bmatrix}
  x \\ y \\ z
\end{bmatrix}
```

where $W_i$ represents the weight for each component and $(\mathbf r_{\text{cg}})_i$ is the position vector between the origin and the CG of the $i$th component. The product in the form $W_i(\mathbf r_{\text{cg}})_i$ is also referred to as the moment induced by the $i$th component.

Considering a takeoff gross weight of 766000 lbs and using Raymer's reference data, the specific weight and position parameters of the structural components are shown in the following table:

Components | Loading (kg/m²) | Reference Area (m²) | Approximate Location
:-------- | :-----: | :----------:|----------:
Wing     | 316  | $(S_w)    | 40% MAC
Horizontal tail     | 170  | $(projected_area(htail))     | 40% MAC
Vertical tail     | 170  | $(S_v)   | 40% MAC
Fuselage     | 155.3  | $(S_f)    | 40-50% Length

Components | Weight Ratio | Reference Weight (lbf) | Approximate Location
:-------- | :-----: | :----------:|----------:
Nose landing gear | $(round((WR_noseLG); digits = 4))| $(MTOW) | Centroid
Main landing gear | $(round((WR_mainLG); digits = 4))| $(MTOW) | 59% Length
Installed engine  | $(WR_engine)	| $(W_engine*9.81)   | Centroid
“All-else empty”  | $(WR_allelse)  | $(MTOW)) | 40-50% Length
Fuel 			  | 1 	| $((cruise1FF* MTOW_kg - W_payload_kg - W_crew_kg - W_empty_kg)*9.81) | 40% MAC
PAX 			  | 1 |$(W_payload_kg*9.81) | 30% Length


Note: We consider the **nose** as the reference point and **clockwise moments** as positive!
	"

# ╔═╡ 51603775-b312-40f4-8ca2-4ff3b8ce1df3
md"For the previously generated wing, the total longitudinal moment (with MAC at $40%) with respect to the nose as origin is:"

# ╔═╡ a035dbaf-62ee-49e9-99cf-38474d2f8239
M_w = (10 * S_w) * mac40_wing.x # Moment generated by wing weight

# ╔═╡ a9d8a708-ffb2-4c3e-9796-7250ea2d570e
md" ### Aircraft Component Centroids with respect to the length and nose
"
# M = r × F
# using LinearAlgebra
# M_tot = sum(cross(r, F) for (F, r) in zip(values(weight_position_3D))) 

# ╔═╡ 1c522282-c014-4c60-94a2-cb9ccc65a2c9


# ╔═╡ a958ee18-9741-4f50-bc5b-db661e722ef1
begin
	x_nose 	= fuse.affine.translation.x 	# Nose location 
	x_fuse 	= x_nose + 0.5 * fuse.length   	# Fuselage centroid (50% L_f)
	x_other = x_nose + 0.4 * fuse.length 	# All-other component centroid (40% L_f)

	# Items to be modified
	x_nLG  	= x_nose + 0.15 * fuse.length  	# Nose landing gear centroid (15% L_f) 
	x_mLG 	= x_nose + 7.891690147286708 #(original) Main landing gear centroid (55% L_f) 
	x_fuel 	= mac40_w.x
	x_pax 	= x_nose + 0.4 * fuse.length 	# (30% L_f) guess ourself
	x_crew = x_nose + 0.13 * fuse.length 	# (13% L_f) guess ourself
end

# ╔═╡ 5b1f6cc3-2298-451e-aa56-9909a48be0e2
md"""The weight and CG position of each component can hence be computed and included in a dictionary for convenience in calculations."""

# ╔═╡ f41ff9aa-c70b-4549-9a15-3b99d126df4d
weight_position_cruise = Dict(	
	"engine" 	=> (WR_engine * 2 * W_engine, 	eng_L.x), 	# Engines (2 × weight)
	"wing"   	=> (Rjet_WingArea * wing_loading, 	mac40_w.x), # Wing, 40% MAC
	"htail"  	=> (S_h * htail_loading, 	mac40_h.x), # HTail, 40% MAC
	"vtail"  	=> (S_v * vtail_loading, 	mac40_v.x), # VTail, 40% MAC
	"fuse"   	=> (S_f * fuse_loading , 	x_fuse), 	# Fuse, centroid
	"all-else" 	=> (WR_allelse * TOGW, 	x_other),
	"noseLG" 	=> (WR_noseLG * TOGW, 	x_nLG), 
	"mainLG" 	=> (WR_mainLG * TOGW, 	x_mLG), #x_mLG
	"fuel"      => (cruise1FF*TOGW - W_payload_kg - W_crew_kg - W_empty_kg, 	mac40_w.x), # Wing, 40% MAC 
	"pax"       => (W_payload_kg, 	x_pax), # (30% L_f)
	"crew" 		=> (W_crew_kg, 	x_crew), 	# (13% L_f)
);

# ╔═╡ 40ceba2c-77ff-46f8-ac0f-312a4048a24b
W_wing, x_wing = weight_position ["wing"] # Get weight and position of 'wing' entry

# ╔═╡ b016fd49-d835-4b2f-972b-08d0e34a51d3
keys(weight_position_cruise) # Get keys of the dictionary

# ╔═╡ d0858655-e5b8-4f96-b64a-3020e3b1b4f2
keys(weight_position_cruise) # Get corresponding values of the dictionary

# ╔═╡ fa4df0a2-737c-4dd7-ae77-f1f560640eb0
md"### CG calculation (Cruise 1)"

# ╔═╡ d7c1c037-5069-43fd-a7ee-c5a76b4ca08a
md"Now we can calculate the total longitudinal moments generated from all the components, i.e., $\sum_i W_i x_{\text{cg}_i}$"

# ╔═╡ 907924e5-cc54-4041-a79c-3e1c683cb975
moments = [ weight * pos_x for (weight, pos_x) in values(weight_position_cruise) ]

# ╔═╡ d6ed6a4b-2b1b-4a4b-be74-73ff1f4eeb18
M_sum_cruise1 = sum(moments) # Sum all moments in 2D

# ╔═╡ 892f379a-431b-4d3f-9ade-d1e483dba4df
md"Now we can calculate the total weight generated from all the components
i.e., $\sum_i W_i$
"

# ╔═╡ e95ddfe9-35c3-4fa8-ad8f-5a2ecb264d63
W_sum_cruise1 = sum(weight for (weight, pos_x) in values(weight_position_cruise)) # Sum weights

# ╔═╡ 7e7f06bc-0891-45df-a1f9-c2fab50a2d90
# Remaining Fuel in kg
W_sum_cruise1 - W_empty_kg - W_crew_kg - W_payload_kg 

# ╔═╡ a3131538-9c84-43dd-b6e2-1a0f172b65b1
md"#### CG location from Aircraft Nose $(m)$
```math
\mathbf{r}_\text{cg} = \frac{\sum_i W_i \ (\mathbf{r}_{\text{cg}})_i}{\sum_i W_i}, \quad \mathbf{r} = \begin{bmatrix}
  x \\ y \\ z
\end{bmatrix}
```
"

# ╔═╡ 0dea76cf-7624-4edb-a6d1-deac05d75777
x_cg = M_sum_cruise1 / W_sum_cruise1	# Compute center of gravity, m

# ╔═╡ c33b0b8c-06e3-48e3-8ad5-f509bd81775c
begin
	T_TO_e = 12543.98 # one engine, FJ44-3A, CJ3 G2 parameter, in Newtons
	y_t = 1.59/2 + 1.8/2 #horizontal distance between engine and fuselage
	
	N_t_crit = T_TO_e * y_t
	N_D = 0.25 * N_t_crit # 0.25 for high-BPR jet
	
	criticalYaw = N_D + N_t_crit
	println("The N_D + N_t_crit value is: ", criticalYaw)
	
	F_v = MTOW_kg * 9.81 * sin(5)
	N = (11.2026 - x_cg) * MTOW_kg * 9.81 * sin(-25) # 25 degree of deflection
	println("The yawing moment from rudder is: " ,N)
	
end

# ╔═╡ 9e1388f4-eb05-4218-bc5d-8254f06e5f95
md"### Neutral Point"

# ╔═╡ 09ab7f40-db5b-4358-9979-7a6e92dff622
md"""

The neutral point is:
```math
\frac{x_{np}}{\bar c} = V_h\frac{C_{L_{\alpha_h}}}{C_{L_{\alpha_w}}} - \frac{\partial C_{m_f}}{\partial C_L}, \qquad V_h = \frac{S_h l_h}{S_w \bar c}
```
"""

# ╔═╡ 231e67c4-d41f-4a6d-90e7-150dc258706e
neutral_point(V_h, CL_ah, CL_aw, Cm_fuse_CL) = V_h * CL_ah / CL_aw - Cm_fuse_CL

# ╔═╡ 6e85b23d-4e35-41db-92d2-4551f0332c93
md"""3 parameters are unknown after the sizing and placement of the empennage:
1. The lift curve slope for the wing $C_{L_{\alpha_w}}$ 
2. The lift curve slope of the horizontal stabilizer $C_{L_{\alpha_h}}$ 
3. Derivative of pitching moment of fuselage (including other components) with respect to $C_L$ $\frac{\partial C_{m_{f}}}{\partial C_L}$ 
"""

# ╔═╡ 7f9321b3-84cc-43ba-a639-b4c12ee54de4
M # Operating cruise Mach number

# ╔═╡ 89bc5817-10c5-43b0-8b7f-2faf27a046f9
x_cg - mac40_wing.x

# ╔═╡ f63bf6dd-ff5d-4d3c-8c9b-2b79ea58d794
md"### Wing Contribution"

# ╔═╡ c46b7178-44aa-4afa-96aa-0495660f1364
md"""
The wing lift curve slope can be approximated using the DATCOM formula.
```math
 C_{L_{\alpha_w}} \approx \frac{2\pi AR_w}{2 + \sqrt{(AR_w/\eta)^2 (1 + \tan^2\Lambda_w - M^2) + 4}}
```
"""

# ╔═╡ 0ab1a78c-e42d-4d08-98e0-c988ff19105b
eta = 0.97 # Aerodynamic efficiency factor (for DATCOM formula)

# ╔═╡ e13771fe-f7db-40a2-8d18-0f3f204376b2
lift_slope_DATCOM(AR, eta, sweep_LE, M) = 
   2π * AR / (2 + sqrt((AR / eta)^2 * (1 + tan(sweep_LE)^2 - M^2) + 4))

# ╔═╡ dd0a4123-f924-40e4-beda-43cc26a8b315
CL_a_w = lift_slope_DATCOM(AR_w, eta, lambda_w, M) # 1/radians

# ╔═╡ c387345f-d0ca-4d63-895d-2618b7719efa
md"### Horizontal Tail Contribution"

# ╔═╡ 91e3c6a3-35ea-4e0b-a25f-e7678a765bf5
md"""
The downwash effect on the lift curve slope of the horizontal stabilizer is estimated by applying lifting line theory. For an elliptically loaded structure:
```math
C_{L_{\alpha_h}} = C_{L_{\alpha_{h_0}}} \left(1 - \frac{\partial \epsilon}{\partial \alpha} \right)\eta_h, \qquad \frac{\partial \epsilon}{\partial \alpha} \approx \frac{2C_{L_{\alpha_w}}}{\pi AR_w}
```

where $\epsilon$ is the _downwash angle_, and $\eta_h$ is the horizontal stabilizer aerodynamic efficiency which accounts for changes in the flow due to the wing.
"""

# ╔═╡ bc747241-5782-4015-b526-ebbdf2df1043
downwash_slope(cl_al_w, AR_w) = 2 * cl_al_w / (π * AR_w)

# ╔═╡ 2611b47d-4236-498b-91e6-8818f33f24bf
function lift_slope_tail_DATCOM(AR_h, eta_h, sweep_LE_h, M, cl_a_w, AR_w)
	dCL_dα = lift_slope_DATCOM(AR_h, eta_h, sweep_LE_h, M) # DATCOM dCₗ/dα
	dε_dα = downwash_slope(cl_a_w, AR_w) # Downwash slope estimation
	cor = (1 - dε_dα) * eta_h # Correction factor
	
	return dCL_dα * cor # Corrected lift-curve slope
end

# ╔═╡ 9aec2739-be59-4b7a-8eb9-f65404bac1e8
eta_h = 0.88 # Horizontal stability aerodynamic efficiency factor (for DATCOM)

# ╔═╡ ec42f737-64cb-4c95-b433-ca4ceece2c76
CL_a_h = lift_slope_tail_DATCOM(AR_h, eta_h, lambda_h, M, CL_a_w, AR_w) # 1/radians

# ╔═╡ 0dc02c5e-0373-475c-870b-10a4ac52bfb3
md""" ### Fuselage Contribution"""

# ╔═╡ be9ce077-eb3b-4cd4-b6a1-701b007cd5e1
md"The moment-lift derivative of the fuselage is estimated via slender-body theory, which primarily depends on the volume of the fuselage. 

```math
\frac{\partial C_{m_f}}{\partial C_L} \approx \frac{2\mathcal V_f}{S_w \bar{c}C_{L_{\alpha_w}}} 
```
"

# ╔═╡ f7add8fa-334a-4ba9-b647-820ea2514eca
 # Fuselage moment-lift derivative
fuse_Cm_CL(vol_fuse, Sw, c_bar, CL_a_w) = 2 * vol_fuse / (Sw * c_bar * CL_a_w)

# ╔═╡ a1102dc4-dcb7-4932-8bd0-6d10ba665e6e
Cm_f_CL = fuse_Cm_CL(V_f, S_w, c_w, CL_a_w)

# ╔═╡ 65cf2d4e-53d2-42b3-8f93-83032dfb904a
md"### Static Margin"

# ╔═╡ 0a99cf1e-7b66-4dbb-bfbe-bb90a5e92ea7
x_np_by_c = neutral_point(V_v, CL_a_h, CL_a_w, Cm_f_CL) # (xₙₚ/c̄)

# ╔═╡ a5a37d86-ce8a-4c93-b3aa-557d33174591
x_np = mac40_wing.x + x_np_by_c * c_w 		# Translate from the wing MAC

# ╔═╡ a47e0be1-d1c3-447f-a330-89459fc6eb0a
begin
	# Position vectors for plots
	r_cg  = [x_cg, 0, 0]  			  # Center of gravity
	r_np  = [x_np,  0., 0.] 		  # Neutral point
end

# ╔═╡ b3bd5e96-fe77-4969-aca2-7a91cf466ce4
md"So we obtain the static margin as:"

# ╔═╡ 0f5f5ea5-c674-4334-a050-5ae84d980f31
x_fuel

# ╔═╡ 93f8e1b6-4555-4644-a4e5-170503efae96
mac40_w.x

# ╔═╡ 9fcc1131-1339-4fb5-a30b-fc2ac4ff4c46
SM = 100((x_np - x_cg) / c_w)
# in percentage

# ╔═╡ af7f5c3c-6005-41a3-8e41-bec335494035
md"### Visualization"

# ╔═╡ c0c58a6b-5b0b-4171-bb96-2980e9d80946
name = "RJet stability"

# ╔═╡ ddc77cb3-52b0-4787-b752-ed500f42b8f0
begin
	plt = plot(
		xaxis = "x",yaxis = "y",zaxis = "z",
		aspect_ratio = 1,
	    camera = (ϕ,φ),
		zlim = (-0.5,0.5) .* span(wing)
	)
    plot!(wing, label = name)
	plot!(plt, htail, label = "Horizontal Tail")
    plot!(plt, vtail, label = "Vertical Tail")
end

# ╔═╡ 0e3d76ee-c639-4b5d-8856-d116963992dd
begin
	plot!(
	plt,
	system, # vortex lattice system
	wing_mesh, # lifting surface
	span = 5, # number of steamlines per spanwise section 
	dist = 10, # distance of steamlines (m)
	)
	plot!(plt, system, htail_mesh, span = 3, lc = :cyan) # For horizontal tail
    plot!(plt, system, vtail_mesh, span = 2, lc = :cyan) # For vertical tail
end

# ╔═╡ 4f72fdd6-10f3-4768-aee6-5c6bff8ffc93
begin
	plot(plt, wing_mesh,label = name)
	plot!(plt, htail_mesh, label = "")
    plot!(plt, vtail_mesh, label = "")
end

# ╔═╡ c466a8bb-d930-4580-a35e-e4df445da3a2
sliders

# ╔═╡ 544a5926-94a2-4870-ae31-f624c0e0febf
md"""
# CG Envelope

"""

# ╔═╡ 89286624-2144-4a37-ab99-843434976356
md"""
	### CG length measured from the NOSE
	"""

# ╔═╡ 5e13883f-66cd-496c-b75e-299e10ce4422
mac40_w.x

# ╔═╡ f1a18ca4-3142-416a-b747-8bf02f2c8c22
md"### CG calculation (Empty-case 1)"

# ╔═╡ d13f5fc8-ce15-4653-b666-f16a535b5f0a
weight_position_empty = Dict(	
	"engine" 	=> (WR_engine * 2 * W_engine, 	eng_L.x), 	# Engines (2 × weight)
	"wing"   	=> (Rjet_WingArea * wing_loading, 	mac40_w.x), # Wing, 40% MAC
	"htail"  	=> (S_h * htail_loading, 	mac40_h.x), # HTail, 40% MAC
	"vtail"  	=> (S_v * vtail_loading, 	mac40_v.x), # VTail, 40% MAC
	"fuse"   	=> (S_f * fuse_loading , 	x_fuse), 	# Fuse, centroid
	"all-else" 	=> (WR_allelse * TOGW, 	x_other),
	"noseLG" 	=> (WR_noseLG * TOGW, 	x_nLG), 
	"mainLG" 	=> (WR_mainLG * TOGW, 	x_mLG),
);

# ╔═╡ 3cc85e09-5968-45d5-acb5-c4e6f7b93a8e
begin
	moments_empty = [ weight * pos_x for (weight, pos_x) in values(weight_position_empty) ]
	
	M_sum_empty = sum(moments_empty)
	
	W_sum_empty = sum(weight for (weight, pos_x) in values(weight_position_empty)) 

	x_cg_empty = M_sum_empty / W_sum_empty

end

# ╔═╡ 40866816-8b0a-4b74-b81c-bc004190a05b
begin
	x_cg_empty_a = abs(x_nose) + x_cg_empty
	x_crew_a = abs(x_nose) + x_crew
	x_pax_a = abs(x_nose) + x_pax
	x_fuel_a = abs(x_nose) + x_fuel
	####
	x_fuse_a 	= abs(x_nose) + x_fuse
	x_other_a 	= abs(x_nose) + x_other 
	x_nLG_a  	= abs(x_nose) + x_nLG 
	x_mLG_a 	= abs(x_nose) + x_mLG
	
end;

# ╔═╡ 26c7809e-55c0-45b9-abfe-154fd0e3cd27
md"""
### Loading Scenarios

Case | Weight Group | $W_i (kg)$ | $x_{cg_{actual}} (m)$
:-------- | :-----: | :----------:|----------:|
1 | Empty | $(round(W_sum_empty; digits = 2)) |  $(round(x_cg_empty_a; digits = 4))
2 | Crew | $(W_crew_kg) | $(round(x_crew_a; digits = 4))
3 | Fuel | $(round(W_total_fuel_kg; digits = 2)) |  $(round(x_fuel_a; digits = 4))
4 | Payload | $(W_payload_kg) |  $(round(x_pax_a; digits = 4))

**The zero value (origin) of $x_{cg_i}$ is located at $(abs(x_nose)) m after the nose**

Possible Loading Sequences:
**1>2>3>4** or **1>2>4>3** or **1>3>2>4** or **1>3>4>2** or **1>4>2>3** or **1>4>3>2**
"""

# ╔═╡ 4ce0e3e7-578b-45e1-ba17-712b38ae4ea5
x_cg_empty_a

# ╔═╡ 4eabb607-6190-4441-bf07-6505cac37e3c
weight_position_CGenvelope = Dict(
	"empty" => (W_sum_empty, x_cg_empty_a), # Weight (kg), Distance measured from nose (m)
	"crew" => (W_crew_kg, x_crew_a),
	"fuel" => (W_total_fuel_kg, x_fuel_a),
	"pax" => (W_payload_kg, x_pax_a),
	
)

# ╔═╡ 866f67bb-c6fa-479d-8b7b-3baff28e4177
keys(weight_position_CGenvelope)

# ╔═╡ 7c6927fe-e574-4fdb-8960-ed92021b1423
values(weight_position_CGenvelope)

# ╔═╡ ad6e2df2-1851-4954-887d-7b8ef91f4b66
md"""
### Loading Cases Combinations

"""

# ╔═╡ bd3e8793-fd63-4f08-802b-aa538584b5ab
# Case 1+2
begin
	M_sum_12 = W_sum_empty * x_cg_empty_a + W_crew_kg * x_crew_a
	
	W_sum_12 = W_sum_empty + W_crew_kg

	x_cg_12 = M_sum_12 / W_sum_12

	[W_sum_12, x_cg_12]
end

# ╔═╡ ae53a714-a365-47c9-ad98-ad1afa42a188
# Case 1+3
begin
	M_sum_13 = W_sum_empty * x_cg_empty_a +W_total_fuel_kg * x_fuel_a
	
	W_sum_13 = W_sum_empty + W_total_fuel_kg

	x_cg_13 = M_sum_13/ W_sum_13

	[W_sum_13, x_cg_13]
end

# ╔═╡ 6bec3770-32bb-421a-81c0-ab1377e2a016
# Case 1+4
begin
	M_sum_14 = W_sum_empty * x_cg_empty_a + W_payload_kg * x_pax_a
	
	W_sum_14 = W_sum_empty + W_payload_kg

	x_cg_14 = M_sum_14/ W_sum_14

	[W_sum_14, x_cg_14]
end

# ╔═╡ 4c328c49-1cea-4cce-ba13-39b255d2c58b
# Case 1+2+3 // 1+3+2 
begin
	M_sum_123 = W_sum_empty * x_cg_empty_a + W_crew_kg * x_crew_a + W_total_fuel_kg * x_fuel_a
	
	W_sum_123 = W_sum_empty + W_crew_kg + W_total_fuel_kg

	x_cg_123 = M_sum_123/ W_sum_123

	[W_sum_123, x_cg_123]
	
end

# ╔═╡ c0d3247a-cbc5-4b1a-906e-46e8eae3ed76
# Case 1+2+4 // 1+4+2
begin
	M_sum_124 = W_sum_empty * x_cg_empty_a + W_crew_kg * x_crew_a + W_payload_kg * x_pax_a
	
	W_sum_124 = W_sum_empty + W_crew_kg + W_payload_kg

	x_cg_124 = M_sum_124/ W_sum_124

	[W_sum_124, x_cg_124]
	
end

# ╔═╡ 16510ddd-8e7f-4317-a2da-266a01b54a79
# Case 1+3+4 // 1+4+3
begin
	M_sum_134 = W_sum_empty * x_cg_empty_a + W_total_fuel_kg * x_fuel_a+ W_payload_kg + x_pax_a
	
	W_sum_134 = W_sum_empty + W_total_fuel_kg + W_payload_kg

	x_cg_134 = M_sum_134/ W_sum_134

	[W_sum_134, x_cg_134]
	
end

# ╔═╡ 16d8d07d-db69-437e-aef7-718d101c94d4
# Case 1234 // 1243 // 1324 // 1342 // 1432 // 1423 
begin
	
	M_sum_1234 = sum(weight * pos_x for (weight, pos_x) in values(weight_position_CGenvelope))
	
	W_sum_1234 = sum(weight for (weight, pos_x) in values(weight_position_CGenvelope))

	x_cg_1234 = M_sum_1234 / W_sum_1234

	[W_sum_1234, x_cg_1234]

	
end

# ╔═╡ facdf55d-8ee1-47b1-87b7-3ff2dec1d990
begin
	# Setting up x and y values
	W_1234 = [W_sum_empty, W_sum_12, W_sum_123, W_sum_1234]
	x_1234 = [x_cg_empty_a, x_cg_12, x_cg_123, x_cg_1234 ]
	
	W_1243 = [W_sum_empty, W_sum_12, W_sum_124, W_sum_1234]
	x_1243 = [x_cg_empty_a, x_cg_12, x_cg_124, x_cg_1234]

	W_1324 = [W_sum_empty, W_sum_13, W_sum_123, W_sum_1234]
	x_1324 = [x_cg_empty_a, x_cg_13, x_cg_123, x_cg_1234]
	
	W_1342 = [W_sum_empty, W_sum_13, W_sum_134, W_sum_1234]
	x_1342 = [x_cg_empty_a, x_cg_13, x_cg_134, x_cg_1234]

	W_1423 = [W_sum_empty, W_sum_14, W_sum_124, W_sum_1234]
	x_1423 = [x_cg_empty_a, x_cg_14, x_cg_124, x_cg_1234]

	W_1432 = [W_sum_empty, W_sum_14, W_sum_134, W_sum_1234]
	x_1432 = [x_cg_empty_a, x_cg_14, x_cg_134, x_cg_1234]

	# Construct Plots
	
	p_1234 = plot(x_1234, W_1234, title = "Loading Path 1234", label = false)
	p_1243 = plot(x_1243, W_1243, title = "Loading Path 1243", label = false)
	p_1324 = plot(x_1324, W_1324, title = "Loading Path 1324", label = false)
	p_1342 = plot(x_1342, W_1342, title = "Loading Path 1342", label = false)
	p_1423 = plot(x_1423, W_1423, title = "Loading Path 1423", label = false)
	p_1432 = plot(x_1432, W_1432, title = "Loading Path 1432", label = false)

	#s_1234 = scatter(x_1234, W_1234, label = false)
	#s_1243 = scatter(x_1243, W_1243, label = false)
	#s_1324 = scatter(x_1324, W_1324, label = false)
	#s_1342 = scatter(x_1342, W_1342, label = false)
	#s_1423 = scatter(x_1423, W_1423, label = false)
	#s_1432 = scatter(x_1432, W_1432, label = false)
	
	# Make 6 subplots
	
	plt_cg = plot(p_1234, p_1243, p_1324, p_1342 , p_1423, p_1432,
		xlimits = (6.,8.),
		ylimits = (2000, 5000),
		xlabel = "CG Position Measured from Aircraft Nose (m)", 
		ylabel = "Weight of Aircraft (kg)",
		xtickfont = font(6),
		ytickfont = font(6),
		guidefont = font(6),
		titlefont = font(10)
	)
	
end

# ╔═╡ cec6b599-3a78-4924-9b0f-2fd0b68edb81
# CG Limits
begin
	x_cg_mostforward = x_cg_134
	x_cg_mostaft = x_cg_13
	x_cg_diff = x_cg_mostaft - x_cg_mostforward

	[x_cg_mostforward, x_cg_mostaft, x_cg_diff]
end

# ╔═╡ 485c39c0-3a4d-46a8-8d86-95b3ddc00948
md" ### Loading diagram (potato diagram)"

# ╔═╡ f0d88a8e-8587-4355-80d0-207eb10de394
begin
	x_mostforward = [x_cg_mostforward, x_cg_mostforward]
	x_mostaft = [x_cg_mostaft, x_cg_mostaft]
	x_maxload = [x_cg_1234,x_cg_1234]
	y_loading = [2000, 5000]
	
	
	plt_potato = plot(x_1234, W_1234, label = "Loading Path 1234",
		title = "Loading Diagram",
		xlimits = (6.,8.),
		ylimits = (2000, 5000),
		xlabel = "CG Position Measured from Aircraft Nose (m)", 
		ylabel = "Weight of Aircraft (kg)",
		legend = :bottomleft,
		#xtickfont = font(6),
		#ytickfont = font(6),
		#guidefont = font(6),
		#titlefont = font(10)
	)
	plot!(x_1243, W_1243, label = "Loading Path 1243")
	plot!(x_1324, W_1324, label = "Loading Path 1324")
	plot!(x_1342, W_1342, label = "Loading Path 1342")
	plot!(x_1423, W_1423, label = "Loading Path 1423")
	plot!(x_1432, W_1432, label = "Loading Path 1432")

	scatter!(x_1234, W_1234, label = false)
	scatter!(x_1243, W_1243, label = false)
	scatter!(x_1324, W_1324, label = false)
	scatter!(x_1342, W_1342, label = false)
	scatter!(x_1423, W_1423, label = false)
	scatter!(x_1432, W_1432, label = false)

	# CG limits
	plot!(x_mostforward, y_loading, linestyle=:dash, label = "x_cg Most Forward")
	plot!(x_mostaft, y_loading, linestyle=:dash, label = "x_cg Most Aft")
	plot!(x_maxload, y_loading, linestyle=:dash, label = "x_cg at MTOW")
end

# ╔═╡ ca893747-96f1-4281-a703-f67b8058e302
md"# Landing Gear Sizing"

# ╔═╡ 56377a6a-2937-410e-be43-88bb45e16961
md"""

### Longitudinal Tip-over Criterion


##### Tricycle Gears
Main landing gears must be behind the aft C.G. location, usually a **15 degree** angle between the vertical gear position and aft CG/gear line.

### Lateral Tip-over Criterion


##### Overturn Angle

A measure of the aircraft's tendency to overturn when taxied around a sharp corner. Should be less than **55 degrees**.

Measured from **most forward CG** to the main wheel, seen from the rear at the location where the main wheel is aligned with the nose wheel



"""

# ╔═╡ e13a30cd-2ec1-4bf8-8f5e-408780f229fc
md"""

### Ground Clearance Criteria

#### FAR 23.925

For each airplane with nose wheel landing gear:

Clearance of at least **7 inches (0.1778 m)** between each propeller and the ground with the landing gear statically deflected and in the level, normal takeoff, or taxing attitude. 
"""

# ╔═╡ ad69331d-bbd9-48da-87eb-7541d4d40880
md"""
### List of Landing gear Requirements in FAR 23

Parameter |  Value | Description
:-------- | :-----: | ----------:
$\psi$ 				| < 55	| 	Overturn Angle (deg)
$H_{clearance}$ 	| 	0.1778 	| Ground Clearance (m)
$\theta_{LOF}$ 		| 	> 15 	| Aft Fuselage Ground Clearance Angle (deg)
$\phi$|    > 5    | Lateral Ground Clearance Angle (deg)
$N_{gear}~per~strut$ | 1 | Number of Gear per strut (aircraft weight < 50000 lbs)
"""

# ╔═╡ 18ad27b4-9862-4771-acb0-92a3888e9781
begin
	h_clearance = 0.9 			  #(m) Ground clearance // Gear length
	H = h_clearance + fuse.radius
	h_dist = H * tan(deg2rad(15)) #(m) Horizontal distance between main LG and aft CG
	l_dist = 1.6				  #(m) Lateral distance between main LG and aft CG
end

# ╔═╡ 61ad5c87-1816-435e-ba7a-917b2626ee8c
# Distance between fuselage nose and MAIN gear strut
x_mainLG = x_cg_mostaft + h_dist #(m)

# ╔═╡ 5bcdb98d-8cd4-48b7-aa51-4b0aa8901519
# Distance between fuselage nose and NOSE gear strut
x_noseLG = abs(x_nose) + x_nLG

# ╔═╡ 4e31235f-5aa7-4264-a417-c9fda3c60969
md"""

### Center of Gravity Breakdown

Components | Weight (kg)  | X-Distance from Nose (m) 
:-------- | :-----: | :----------:|
Fuselage    		| $(round(S_f * fuse_loading; digits = 4))	| $(round(x_fuse_a; digits = 4))    
Wing     			| $(round(Rjet_WingArea * wing_loading; digits = 4))   | $(round(abs(x_nose) + mac40_w.x; digits = 4))   	
Horizontal tail     | $(round(S_h * htail_loading; digits = 4))  | $(round(abs(x_nose) + mac40_h.x; digits = 4))     
Vertical tail   	| $(round(S_v * vtail_loading;digits = 4))  | $(round(abs(x_nose) + mac40_v.x; digits = 4))  
Engine 			    | $(round(WR_engine * 2 * W_engine; digits = 4))  | $(round(abs(x_nose) + eng_L.x; digits = 4))
Nose Landing Gear   | $(round(WR_noseLG * TOGW; digits = 4))  | $(round(x_noseLG; digits = 4))
Main Landing Gear   | $(round(WR_mainLG * TOGW; digits = 4 ))  | $(round(x_mainLG; digits = 4))
All-else Empty 		| $(round(WR_allelse * TOGW; digits = 4)) | $(round(abs(x_nose) + x_other; digits = 4))
Crew   				| $(W_crew_kg)  | $(x_crew_a)
Fuel 				| $(round(W_total_fuel_kg; digits = 4))  | $(round(x_fuel_a; digits = 4))
Passenger 			| $(W_payload_kg)  | $(round(x_pax_a; digits = 4))

MTOW = $(round(S_f * fuse_loading + Rjet_WingArea * wing_loading + S_h * htail_loading + S_v * vtail_loading + WR_engine * 2 * W_engine + WR_noseLG * TOGW + WR_mainLG * TOGW + W_crew_kg + W_total_fuel_kg + W_payload_kg + WR_allelse * TOGW; digits = 4)) kg

"""


# ╔═╡ e7210a3e-f4ec-4179-9adc-03e9da785250
begin 
	r_mLG_L = [x_mainLG + x_nose, -l_dist, -fuse.radius] # Left Main landing gear
	r_mLG_R = [x_mainLG + x_nose, l_dist, -fuse.radius] # Right Main landing gear
	r_nLG = [x_noseLG + x_nose, 0., -fuse.radius] # Nose landing gear
	r_fuel = [x_fuel, 0., -0.60] 		# Fuel same as wing location
	r_pax =  [x_pax, 0., -0.30] 			# Pax
	r_crew = [x_crew, 0., -0.30] 			# Crew
	r_engine_L = eng_L 				# Left Engine
	r_engine_R = eng_R 				# Right Engine
	r_other = [x_other, 0., 0.]
	r_fuse = [x_fuse, 0., 0.]
end

# ╔═╡ 236b6d70-f948-42ce-a7d5-52551941447e
begin
	p3 = plot(
		# aspect_ratio = 1, 
		zlim = (-0.5, 0.5) .* span(wing),
		camera = (ϕ,φ),
		size = (1000,800),
		palette = :Dark2_5,
	)
	# Surfaces
	plot!(fuse, alpha = 0.3, lw = 3, lc = :cornflowerblue, label = "Fuselage")
	plot!(wing_mesh, 0.4, lw = 2.5, label = "Wing") 			 # 40% MAC specified "0.4" for CG
	plot!(vtail_mesh, 0.4, lw = 2.5, label = "Vertical Tail") 	 # 40% MAC specified "0.4" for CG
	plot!(htail_mesh, 0.4, lw = 2.5, label = "Horizontal Tail") # 40% MAC specified "0.4" for CG
	# Surfaces
	#plot!(fuse, alpha = 0.3, label = "Fuselage")
	#plot!(wing, 0.4, label = "Wing") 			 # 40% MAC specified "0.4" for CG
	#plot!(htail, 0.4, label = "Horizontal Tail") # 40% MAC specified "0.4" for CG
	#plot!(vtail, 0.4, label = "Vertical Tail") 	 # 40% MAC specified "0.4" for CG

	# Engine
	scatter!(Tuple(eng_L), label = "Engine Left")
	scatter!(Tuple(eng_R), label = "Engine Right")

	# Landing gear
	scatter!(Tuple(r_nLG), label = "Nose Landing Gear")
	scatter!(Tuple(r_mLG_L), label = "Left Main Landing Gear")
	scatter!(Tuple(r_mLG_R), label = "Right Main Landing Gear")

	# CG and NP
	scatter!(Tuple(r_cg), label = "Center of Gravity")
	scatter!(Tuple(r_np), label = "Neutral Point")
end

# ╔═╡ 1b690260-3121-4ea7-a3d0-db048c23fd6c
# Overturn Angle Calculation
begin
	alpha1 = atan(( l_dist / (x_mLG_a - x_nLG_a)))
	Y = (x_cg_mostforward - x_nLG_a)  * sin(alpha1)
	psi = rad2deg(atan(H/Y))
end

# ╔═╡ a4e59ceb-20d2-4530-b538-20b770a96d26
# Aft Fuselage Ground Clearance Angle (deg)
begin
	x_mainLG_rear = fuse.length - x_mainLG
	h_rear = H + fuse.d_rear
	theta = rad2deg(atan(h_rear / x_mainLG_rear)) 
	## for checking
	x_rear_check = fuse.length - (abs(x_nose) + 7.1)
	h_rear_check = fuse.radius + fuse.d_rear
	theta_check = rad2deg(atan(h_rear_check / x_rear_check)) 

	if theta > theta_check
		theta
	else
		theta = "error"
	end 
end

# ╔═╡ 07010575-d08e-4e56-ad37-1e5250f33473
begin # Lateral Ground Clearance Angle
	wing_dihedral1 = dihedrals(wing)[1]
	h_wingtip = h_clearance + spans(wing)[1] * sin(deg2rad(wing_dihedral1))
	horizontal_wingtip = spans(wing)[1] * cos(deg2rad(wing_dihedral1)) - Y
	phi = rad2deg(atan(h_wingtip / horizontal_wingtip))
end

# ╔═╡ 4041f985-c779-4e45-b6e0-d68f82f0623b
md"""
### Selected Values

Parameter |  Value | Description
:-------- | :-----: | ----------:
$\psi$ 		|  $(round(psi; digits = 4))	| 	Overturn Angle (deg)
$H$   	|  $(H) | Height between CG and Static Ground Line (m)
$h_{dist}$|    $(round(h_dist; digits = 4))    | Horizontal distance between main gear and aft CG (m)
$l_{dist}$|    $(round(l_dist; digits = 4))    | Lateral distance between main gear and CG (m)
$h_{clearance}$ 	| 	$(h_clearance) 	| Ground Clearance (m)
$\theta$ 		|  $(round(theta; digits = 4)) 	| Aft Fuselage Ground Clearance Angle (deg)
$\phi$|    $(round(phi; digits = 4))    | Lateral Ground Clearance Angle (deg)
$N_{gear}~per~strut$ | 1 | Number of Gear per strut (aircraft weight < 50000 lbs)

"""

# ╔═╡ 73c5ccf0-0274-4047-964e-833cc6e7d411
md"""
### Load Calculation for Tire Sizing
From Lecture Notes 10 Landing Gear P.24

```math
\begin{align}
\text{Max Static Load main} = W \frac{N_a}{B} \\
\text{Max Static Load nose} = W \frac{M_f}{B} \\
\text{Min Static Load nose} = W \frac{M_a}{B} \\
\text{Dynamic Breaking Load nose} = 0.31 \frac{H}{B} W\\
\end{align}
```
Note that
```math
\frac{M_a}{B} > 0.05 \text{    and    }
\frac{M_f}{B} > 0.20 
```
where $B$ is the base clearance

Wheel Rim diameter = **0.5 diameter** of Tire Mounted
"""

# ╔═╡ 1c5e34bb-bb12-41d5-af13-e89b4ffe1dfa
# Functions for Tire Sizing
begin 
	max_staticload_main(W, Na, B) = W * Na / B
	max_staticload_nose(W, Mf, B) = W * Mf / B
	min_staticload_nose(W, Ma, B) = W * Ma / B
	dynamicload_nose(W, H, B) = 0.31 * W * H / B
end

# ╔═╡ ce15fbeb-0387-45d4-bb08-1b0ed7ca6a26
begin # To be determined
	W_aircraft = W_sum_1234
	Na = x_cg_mostaft - x_noseLG							
	B = x_mainLG - x_noseLG
	Mf = B - (x_cg_mostforward- x_noseLG)							
	Ma = B - Na 
end

# ╔═╡ 741621a2-0407-48b6-a269-287559884a07
begin
	# Weight vectors
	vec_W_engine = [0., 0., WR_engine * W_engine]
	vec_W_wing = [0., 0., Rjet_WingArea * wing_loading]
	vec_W_htail = [0., 0., S_h * htail_loading]
	vec_W_vtail = [0., 0., S_v * vtail_loading]
	vec_W_fuse = [0., 0., S_f * fuse_loading]
	vec_W_allelse = [0., 0., WR_allelse * W_aircraft]
	vec_W_noseLG = [0., 0., WR_noseLG * W_aircraft]
	vec_W_mainLG = [0., 0., WR_mainLG * W_aircraft / 2]
	vec_W_fuel = [0., 0.,  W_total_fuel_kg]
	vec_W_pax = [0., 0., W_payload_kg]
	vec_W_crew = [0., 0., W_crew_kg]
end

# ╔═╡ dee76e66-60d8-455c-8dee-66bab4bcb5ca
weight_position_3D = Dict(	
	"engine_L"  => (vec_W_engine, 	r_engine_L), 	# Engine L (weight)
	"engine_R" 	=> (vec_W_engine, 	r_engine_R), 	# Engine R (weight)
 	"wing"   	=> (vec_W_wing, 	mac40_w), # Wing, 40% MAC
 	"htail"  	=> (vec_W_htail, 	mac40_h), # HTail, 40% MAC
 	"vtail"  	=> (vec_W_vtail, 	mac40_v), # VTail, 40% MAC
 	"fuse"   	=> (vec_W_fuse , 	r_fuse), 	# Fuse, centroid
 	"all-else" 	=> (vec_W_allelse, 	r_other),
 	"noseLG" 	=> (vec_W_noseLG, 	r_nLG), 
 	"mainLG_L" 	=> (vec_W_mainLG , 	r_mLG_L),
	"mainLG_R" 	=> (vec_W_mainLG, 	r_mLG_R), 
 	"fuel"      => (vec_W_fuel, 	r_fuel), # Wing, 40% MAC 
 	"pax"       => (vec_W_pax, 		r_pax), # (30% L_f)
 	"crew" 		=> (vec_W_crew, 	r_crew), 	# (13% L_f)
 );

# ╔═╡ 6c21f5c7-3df2-4571-8639-8e63af644b1d
M_sum_3D = sum(cross(r, F) for (F, r) in values(weight_position_3D))
# Sum all moments in 3D

# ╔═╡ 9e0b6836-609b-4884-b6d0-b26dc10574cd
W_sum_3D = sum(F for (F, r) in values(weight_position_3D))
#Weight in 3D

# ╔═╡ ba74ec55-f4af-47b6-9357-76de7f3079b5
r_cg_3D = [(-M_sum_3D[2]/W_sum_3D[3]), 0.,0.]

# ╔═╡ 5492f7e7-98fb-4ac0-937a-9ab8618345cf
W_sum_3D[3]

# ╔═╡ 225d1e3d-d8e7-4074-90a6-3c079a1e2cf4
# New WS_max Wing Loading
begin
	new_WS_max = W_aircraft * g / Rjet_WingArea
end

# ╔═╡ 93a04579-eed5-457a-a3f9-00f76ca524c9
Ma

# ╔═╡ eb6304ae-abed-4f6e-9ffb-06fc50d7a0b0
B

# ╔═╡ ca82d77b-d0e1-4d5f-8b5c-8697e7984616
W_aircraft

# ╔═╡ 5131a22b-5082-4e97-9a68-71aa26a1e163
# Minimum value for Ma
Ma_min = 0.05 * B

# ╔═╡ 214c7095-caee-4d1a-bae5-b7e7ed56f9b6
# Minimum value for Mf
Mf_min = 0.2 * B

# ╔═╡ 0c0d6d6c-252b-44be-99e2-b56741273679
[Ma/B, Mf/B]

# ╔═╡ 549a0ca3-1e6a-402c-b7bc-3b738fdd2139
begin
	statload_max_main = max_staticload_main(W_aircraft, Na, B)
	statload_max_nose = max_staticload_nose(W_aircraft, Mf, B)
	statload_min_nose = min_staticload_nose(W_aircraft, Ma, B)
	dynaload_nose = dynamicload_nose(W_aircraft, H, B)

	[statload_max_main, statload_max_nose, statload_min_nose, dynaload_nose]
end

# ╔═╡ f8bc7a08-814e-43f2-ac40-66f1c17cea55
md"""
### Braking Requirement Check

Braking Kinetic Energy during landing 

```math
KE_{breaking} = \frac{1}{2} \frac{W_{landing}}{g} V_{stall}^2
```
Braking Kinetic Energy per wheel with brake (number of main landing gear)


"""

# ╔═╡ 0a710675-437c-40fd-8c7a-2a6488f7ef40
# KE Braking
KE_braking(W, V) = 0.5 * W / 9.81 * V^2

# ╔═╡ c3878c17-ccec-4b9b-9b7a-aaac165b45f9
KE_brake = KE_braking(LandingFF*W_aircraft*9.81, V_stall)

# ╔═╡ bbd2ce4e-016d-47e1-8aa0-336a5d5d7cc3
KE_brake_perWheel = KE_brake / 2 # Hence required wheel diameter is between 20-26 cm

# ╔═╡ 42efd4f6-3617-4399-acdd-2bc37ec4db2c
md"""
### Tire Diameter and Width Equation

The basic tire diameter and width can be found by 

```math
\text{Main Wheel Diameter (cm)} = A_{diameter}W_W^{B_{diameter}}
```
```math
\text{Main Wheel Width (cm)} = A_{width}W_W^{B_{width}}
```

where $A_{diameter}$, $B_{diameter}$, $A_{width}$, $B_{width}$ are coefficients that can be found in Statical Tire Sizing Chart, $W_w$ refers to the total weight on the wheel (kg)

Note that the nose tire diameter can be assumed to be 60% - 100% of the main tires
"""

# ╔═╡ a175b9d2-9462-4f27-b36c-82ed5dbefe9e
begin
	# Main wheels diameter or width in (cm) from Statical Tire Sizing Chart
	
	A_diameter = 8.3
	B_diameter = 0.251 

	A_width = 3.5
	B_width = 0.216
end

# ╔═╡ 61af12b2-0720-4ec8-b0a3-18b341d75270
begin
	in_to_cm = 2.54
	cm_to_in = 1/in_to_cm
end

# ╔═╡ 565ab859-2e87-41f4-9af2-b92ba6f9f5ef
# Main Gear Wheel
begin
	d_wheel_mainLG = A_diameter * (statload_max_main/2)^B_diameter
	w_wheel_mainLG = A_width * (statload_max_main/2)^B_width

	[d_wheel_mainLG, w_wheel_mainLG] # (cm)
end

# ╔═╡ 74e985e5-44d7-4f47-aa3a-1d445f6464e3
# Nose Gear Wheel
begin
	d_wheel_noseLG, w_wheel_noseLG = [d_wheel_mainLG, w_wheel_mainLG] * 0.65  # (cm)
end

# ╔═╡ 60087dcd-edf5-48fa-9c00-c40f472e88b6
# Wheel Rim (Approx 0.5 Tire diameter)
begin
	d_rim_mainLG, d_rim_noseLG = [d_wheel_mainLG, d_wheel_noseLG]/2
	# main, nose in cm
end

# ╔═╡ 2a893589-2c69-4f24-a4bb-40aa1225c038
d_wheel_mainLG_inch, w_wheel_mainLG_inch = [d_wheel_mainLG, w_wheel_mainLG]*cm_to_in

# ╔═╡ b12b90d1-c28b-43ea-8f04-70fd25ef5681
d_wheel_noseLG_inch, w_wheel_noseLG_inch = [d_wheel_noseLG, w_wheel_noseLG]*cm_to_in

# ╔═╡ 0737e9d2-be09-4701-8dc3-174082bf71cc
d_rim_mainLG_inch, d_rim_noseLG_inch = [d_rim_mainLG, d_rim_noseLG]*cm_to_in

# ╔═╡ 2ec6effc-1e3c-4a14-9e1b-6a737764c81d
md"""
### Landing Gear Tires Summary

Note: 27(diameter of tire) x 8.5 (width) - 10 (diameter of rim)

#### Requirements
Landing Gear | Tire Dimensions (inch) | Rim Dimensions (inch)
:-------- | :-----: | ----------:
$Main$ 	|  $(round(d_wheel_mainLG_inch;digits = 4)) x $(round(w_wheel_mainLG_inch; digits = 4))	| 	$(round(d_rim_mainLG_inch; digits = 4))
$Nose$   |   $(round(d_wheel_noseLG_inch; digits = 4)) x $(round(w_wheel_noseLG_inch; digits =4)) | $(round(d_rim_noseLG_inch; digits = 4))

#### Selected Tires
Landing Gear | Brand | Dimensions (inch) | Weight (lbs) | Price per each | Application(s) | Quantity
:-------- | :-----: | ----------: | ----------:| ----------: | ----------:| ----------:
$Main$ | Michelin Air 	|  24x7.7-12	| 26 | USD 882.55 | Beechjet400 (MLG) | 2
$Nose$ | Michelin Air	|  15x6.0-6	| 7 | USD 233.95 | Cessna 336, 337 (NLG) | 1
"""

# ╔═╡ ed9a02a0-f09b-4059-b203-3eba4f6633bf


# ╔═╡ bfcdbc9b-b629-401b-8ddd-840925bff3d8
md" # V-n diagram"

# ╔═╡ 73b7d461-123d-4a3d-944f-bdfe78e3343e
md"Functions"

# ╔═╡ b4dde258-279d-4ebb-9831-db46b82be3a3
md"""
We can generally get the speed as a function of the load factor:
```math
V = \sqrt{\frac{2n}{\rho C_L}\left(\frac{W}{S}\right)}
```
"""

# ╔═╡ 1cd25e7a-659f-4671-a015-f25f667a1e23
speed_from_load(n, ρ, WbyS, CL) = sqrt(2WbyS / ρ * abs(n / CL))

# ╔═╡ 569144f5-fecd-4cf1-a427-4cf44f17e3a6
md"""
The load factor, which is inversely a function of the equivalent airspeed, can be expressed as:
```math
n_\text{neg, pos} = \frac{L}{D} = \frac{\rho V^2C_{L_{\min,~\max}}}{2(W/S)}
```
"""

# ╔═╡ f86dc524-e6f3-41f7-b951-e40cadac9043
load_from_speed(ρ, V, CL, WbyS) = ρ * V^2 * CL / 2WbyS

# ╔═╡ b61d8f56-28ec-4528-ba95-b116a5f67824
md"""
### Load Factor Limits

The maximum load factor is usually restricted, e.g. FAR-25 specifications for a jet aircraft $n_\max = 2.5$ (Not my deal ar), or by regulations:

```math
n_\max = \min\left(2.1 + \frac{24000}{(TOGW + 10000)}, 3.8 \right), \quad \text{(TOGW in lbs)}
```

The minimum load factor $n_\min$ should not be less than $-0.4 \times n_{\max}$.
"""

# ╔═╡ 18d2fdfa-4c69-4503-a08c-a8a9727d3d10
load_factor_max(W) = min(2.1 + 24000 / (W + 10000), 3.8) # Maximum load factor limit

# ╔═╡ f3a9ed0e-707f-4ae9-a8ce-81dd822a3318
md"Constrained speed for V-n digram"

# ╔═╡ 4d7c5f67-554b-49ca-9409-871c331ea515
begin
	WbyS_cruis = WbS_stall_2_4*RF_LongRangeCruiseWF #wingloading at cruise with normal stall clmax2.4)
	Clmax_4412 = 1.6706 #RE:1M
	Clmin_4412 = -0.8374
	kg_to_lb = 2.20462 # Convert kg to lb
	num_Vn = 100 # Number of points for plotting lines

end

# ╔═╡ ad7a9b4a-fa65-4b65-8b34-6d845cad4d46
md"Constranined load factor for V-n digram"

# ╔═╡ 9634af66-cef4-4b92-a7d1-1bef51f8a371
begin
		n_stall = 1.0 # Stall load factor
end

# ╔═╡ 45f3da3a-c1e9-44fa-a22e-3b208b44c01a
begin 
	V_S = speed_from_load(n_stall, 1.225, WbyS_cruis, Clmax_4412) #stalling speed at level flight
end

# ╔═╡ cedad643-0bee-41e3-a8f3-784f067e5775
begin
	n_max = load_factor_max((WbS_stall_2_4 / g) * Rjet_WingArea * kg_to_lb) # Maximum load factor (see the appendix for calculation)
	n_min = -0.4 * n_max # Minimum load factor (should not be below -0.4 × nₘₐₓ)no un
	n_pos_stall = load_from_speed(1.225, V_S, Clmax_4412, WbyS_cruis) # Maximum load factor at stall (obviously n = 1 by definition here)
	n_neg_stall = load_from_speed(1.225, V_S, Clmin_4412, WbyS_cruis) # Minimum load factor at stall speed with n = 1
end

# ╔═╡ 95cb307e-cd53-4c13-b10d-bfbaae061d44
md"""
The expression for the load factor under maximum gust intensity is given by [EASA CS-23](https://www.easa.europa.eu/sites/default/files/dfu/decision_ED_2003_14_RM.pdf) and [CS-25](https://www.easa.europa.eu/sites/default/files/dfu/CS-25_Amdt%203_19.09.07_Consolidated%20version.pdf) regulations:
```math
n_\text{gust} = 1\pm\frac{K_{g}C_{L_{\alpha}}U_{e}V_{EAS}}{2(W/S)}
```
"""

# ╔═╡ b5a2bfdf-fa4b-429e-97dd-2f659d9c5f8e
n_gust(Kg, CL_alpha, Ue, V, WbS; positive = true) = 1 + ifelse(positive, 1, -1) * Kg * CL_alpha * Ue * V / 2WbS

# ╔═╡ 90ae52c1-d7bd-4c21-abd1-54f02cc2e519
md"""
By equating the gust load and load factor, the corresponding $V_{B}$ and $n$ can be obtained by solving the following quadratic equation:

```math
\begin{aligned}
n_\text{pos} & = n_\text{gust} \\
\frac{\rho_{SL}V_{EAS}^2C_{L_{\max}}}{2(W/S)} & =  1 + \frac{K_{g}C_{L_{\alpha}}U_{e}V_{EAS}}{2(W/S)}
\end{aligned}
```

Alternatively, you could graphically evaluate the intersection of the two lines described by the expressions on each side.
"""

# ╔═╡ a7230d53-1269-4979-9bee-83bb55d5dbb9
function quadratic_roots(a, b, c)
    d = sqrt(b^2 - 4a*c)
    (-b .+ (d, -d)) ./ 2a
end

# ╔═╡ 35a129ef-e666-4dc5-8fbc-3fac98f5ff73
function gust_load_factor(Kg, CL_alpha, Ue, CL_max, rho, WbyS)
	# Define coefficients for quadratic equation
	a = rho * CL_max / 2WbyS
	b = - Kg * CL_alpha * Ue / (2WbyS)
	c = -1
		
	# Evaluate roots
	VB, VB_wrong = quadratic_roots(a, b, c)

	# Return correct root
	return VB
end

# ╔═╡ 0e321be0-cd63-4181-ba1c-579b02ade9a5
md"""

### Gust Speeds

  Parameter| $20,000~ft$ and below| $50,000~ft$ and above
:----------- | :-----:|:--------:
$U_{e,B}$ (Rough air gust)    | $66~ft/s$ | $38~ft/s$
$U_{e,C}$ (Gust at max design speed) | $50~ft/s$|$25~ft/s$
$U_{e,D}$ (Gust at max dive speed)| $25~ft/s$|$12.5~ft/s$
_Note:_ Linearly interpolated values between $20,000~ft$ and $50,000~ft$.
"""

# ╔═╡ b4ff85b6-904b-4779-990b-7944e4e53820
linear_interp(x, y0, y1, x0, x1) = y0 + (x - x0) * (y1 - y0) / (x1 - x0)

# ╔═╡ fb413d4f-7454-41df-9172-91e4e1e5f8fb
function gust_speeds(alt; units = "m")
    alt = ifelse(units == "m", 3.28084 * alt, alt)

    # Extrema 
    alt_min, alt_max = (20000, 50000)
    Ues_max, Ues_min = (66, 50, 25) .* 0.3048, (38, 25, 12.5) .* 0.3048

    # Conditions
    if alt <= alt_min
        return Ues_max
    elseif alt >= alt_max
        return Ues_min
    else
        Ues_BCD = linear_interp.(alt, Ues_min, Ues_max, alt_max, alt_min)
        return Ues_BCD
    end
end

# ╔═╡ 05526a5d-0076-4dc1-a915-cac04ad91cb1
md"""
The gust alleviation factor $K_{g}$ for subsonic aircraft is given by:
```math
K_{g} = \frac{0.88\mu}{5.3+\mu},\quad \mu= \frac{2(W/S)}{\rho\bar{c}C_{L_\alpha}g}
```
The V-n diagram varies depending on the change in wing loading during flight and the considered altitude.
"""

# ╔═╡ e834d8ed-78bc-4ce3-9eec-18aa7b201f65
mu(WbyS, ρ, c, CL_alpha, g) = 2WbyS / (ρ * c * CL_alpha * g)

# ╔═╡ fb117bd2-a6ee-42d9-8bc2-f1b2496570c1
gust_alleviation(μ) = 0.88μ / (5.3 + μ)

# ╔═╡ 4ff49253-3730-4880-b945-b311947625fe
mu_case = mu(WbyS_cruis, σ_cruise*1.225, c_w, CL_alpha, g) # μ

# ╔═╡ 43ab1a45-c52f-4987-bf8b-167b094dc76e
K_g = gust_alleviation(mu_case) # K_g

# ╔═╡ 542f15e8-3483-4a82-bb93-dd9e5fa1691c
begin
	V_C = a_FL360*√σ_cruise# Cruise EAS, m/s
	V_MO = V_C*1.06 #maximum operating EAS
	V_D = V_C*1.07 #design diving speed ##max level flight speed (For transonic aircraft, VD is usually 7% higher than VMO. For slower aircraft, VD = 1.25VC) since M is 0.76
	V_A = speed_from_load(n_max, 1.225, WbyS_cruis, Clmax_4412) # Corner speed (sea level), m/s
	V_n_neg_stall = speed_from_load(-1, 1.225, WbyS_cruis, Clmin_4412) # Stall speed with minimum CL with n = -1. This would be the case of inverted flight.
	Ue_B, Ue_C, Ue_D = gust_speeds(alt_m; units = "m") # Gust speeds at altitude, m/s
	V_B = gust_load_factor(K_g, CL_alpha, Ue_B, Clmax_4412, 1.225, WbyS_cruis) # Speed at intersection of gust and basic flight envelope, m/s
end

# ╔═╡ 55460fc4-1fa7-4535-8f8f-f2fcdd235854
basic_quantities = begin
	## Ranges
	V_As  = range(0, V_A, length = num_Vn)
	n_pos = load_from_speed.(1.225, V_As, Clmax_4412, WbyS_cruis)

	V_n_min = speed_from_load(n_min, 1.225, WbyS_cruis, Clmin_4412) # Speed at minimum load factor at minimum CL
	V_nminCs = range(V_n_min, V_C, length = num_Vn)
	V_nmaxDs = range(V_A, V_D, length = num_Vn)
	
	V_Amins = range(0, V_n_min, length = num_Vn)
	n_neg   = load_from_speed.(1.225, V_Amins, Clmin_4412, WbyS_cruis)
	n_C_min = range(n_neg[end], n_min, length = num_Vn)
	
	V_CDs = range(V_C, V_D, length = num_Vn)
	n_CDs = range(n_min, 0., length = num_Vn)
	
	ns = range(n_min - 0.4, n_max + 0.4, length = num_Vn)
	V_Ds = range(0, V_D, length = num_Vn)
	V_SAs = range(V_S, V_A, length = num_Vn)
	V_Snmins = range(V_S, V_n_min, length = num)

	V_SAs = range(V_S, V_A, length = num_Vn)

	if n_min < -1
		ns_stall_max = range(0, n_pos_stall, length = num_Vn)
		V_S0s = range(V_S, V_n_neg_stall, length = num_Vn)
		ns_stall_min = range(0, -1, length = num_Vn)
		V_Snmins = range(V_n_neg_stall, V_n_min, length = num_Vn)
	else
		ns_stall_max = range(n_neg_stall, n_pos_stall, length = num_Vn)
		V_S0s = fill(V_S, num_Vn)
		ns_stall_min = range(0, n_neg_stall, length = num_Vn)
		V_Snmins = range(V_S, V_n_min, length = num_Vn)
	end
		
	ns_pos_stall = load_from_speed.(1.225, V_SAs, Clmax_4412, WbyS_cruis)
	ns_neg_stall = load_from_speed.(1.225, V_Snmins, Clmin_4412, WbyS_cruis)

end

# ╔═╡ 32d19a8b-3686-4b3e-b1eb-6f68a1d43a5d
begin
	## Manueverable envelope
	basic = plot(
	    xlabel = "Equivalent Airspeed, V_EAS (m/s)",
	    ylabel = "Load Factor, n",
	    title  = "V-n Diagram, Basic Flight Envelope",
	    legend = :bottomleft,
	    ylim = (n_min - 0.5, n_max + 0.4)
	)
	
	# Vertical lines
	plot!(fill(V_C, num_Vn), ns,
	    line = :dash, 
	    color = :gray,
	    alpha = 0.5,
	    linewidth = 1,
	    label = :none
	) # Design speed
	plot!(fill(V_MO, num_Vn), ns, 
	    line = :dash, 
	    color = :gray,
	    alpha = 0.5,
	    linewidth = 1,
	    label = :none
	) # Maximum operating speed
	plot!(fill(V_D, num_Vn), ns, 
	    line = :dash, 
	    color = :gray,
	    alpha = 0.5,
	    linewidth = 1,
	    label = :none
	) # Design driving speed
	plot!(fill(V_S, num_Vn), ns,
	    line = :dash, 
	    color = :gray,
	    alpha = 0.5,
	    linewidth = 1,
	    label = :none
	) # Stall speed
	plot!(fill(V_A, num_Vn), ns,
	    line = :dash, 
	    color = :gray,
	    alpha = 0.5,
	    linewidth = 1,
	    label = :none
	) # Corner speed
	
	# Horizontal lines
	plot!(V_Ds, fill(n_max, num_Vn), 
	    line = :dash, 
	    color = :gray,
	    alpha = 0.5,
	    linewidth = 1,
	    label = :none
	) # Maximum load factor
	plot!(V_Ds, fill(n_min, num_Vn),
	    line = :dash, 
	    color = :gray,
	    alpha = 0.5,
	    linewidth = 1,
	    label = :none
	) # Minimum load factor
	plot!(V_Ds, zeros(num_Vn),
	    line = :dash, 
	    color = :gray,
	    alpha = 0.5,
	    linewidth = 1,
	    label = :none
	) # Zero load factor
	plot!(V_Ds, ones(num_Vn),
	    line = :dash, 
	    color = :gray,
	    alpha = 0.5,
	    linewidth = 1,
	    label = :none
	) # Unity load factor
	plot!(V_Ds, -ones(num_Vn),
	    line = :dash, 
	    color = :gray,
	    alpha = 0.5,
	    linewidth = 1,
	    label = :none
	) # Negative one load factor
	
	# Maneuverable envelope
	plot!(V_SAs, ns_pos_stall,
	      label = "n_pos"
	     ) # Positive load factor
	
	# If minimum load factor is lesser than -1
	if n_min < -1
		plt_neg = plot!(V_Snmins, ns_neg_stall,
			label = "n_neg",
			color = :black,
		 ) # Negative load factor
		plot!(V_S0s, zeros(num_Vn),
			label = :none,
			color = :black,
		) # Stall speed negative load factor
		plot!(fill(V_n_neg_stall, num_Vn), ns_stall_min,
			label = :none,
			color = :black
		)

	else 
		plot!(V_Snmins, ns_neg_stall,
		  label = "n_neg"
		 ) # Negative load factor
	end
	
	plot!(V_nminCs, n_C_min,
	      label = "n_min" 
	     ) # Minimum load factor
	plot!(V_nmaxDs, fill(n_max, num_Vn),
	      label = "n_max"
	     ) # Maximum load factor
	
	plot!(fill(V_D, num_Vn), range(0, n_max, length = num_Vn),
	      label = "V_max"
	     ) # Maximum operating pseed
	plot!(V_CDs, n_CDs,
	      label = :none
	     ) # Linearly increasing from VC to VD
	
	plot!(fill(V_S, num_Vn), ns_stall_max,
	      label = "V_stall",
	     ) # Stall speed
	
	
	# Vertices
	vertices_1 = [ V_S n_stall "VS" ; 
	               V_A n_max   "VA" ; 
	               V_C n_min   "VC" ; 
	               V_D n_max   "VD" ]
	scatter!(vertices_1[:,1] , vertices_1[:,2], ms = 2, label = :none)
	
	eps = 0.2 # Offset factor for annotations
	annotate!(vertices_1[:,1], vertices_1[:,2] .+ eps, vertices_1[:,3])
	annotate!((V_S + V_D) / 2, (n_min + n_max) / 2, "Maneuverable")
	annotate!((V_S + V_A) / 4, (n_stall + n_max) / 2, text("Positive Stall", 9))
end

# ╔═╡ fb47c667-9939-4d1e-bf23-094707276b8d
gust_quantities = begin
	V_Bs = range(0, V_B, length = num_Vn)
	ngust_B_pos = n_gust.(K_g, CL_alpha, Ue_B, V_Bs, WbyS_cruis)
	ngust_B_neg = n_gust.(K_g, CL_alpha, Ue_B, V_Bs, WbyS_cruis, positive = false)
	
	V_Cs = range(0, V_C, length = num)
	ngust_C_pos = n_gust.(K_g, CL_alpha, Ue_C, V_Cs, WbyS_cruis)
	ngust_C_neg = n_gust.(K_g, CL_alpha, Ue_C, V_Cs, WbyS_cruis, positive = false)
	
	ngust_D_pos = n_gust.(K_g, CL_alpha, Ue_D, V_Ds, WbyS_cruis)
	ngust_D_neg = n_gust.(K_g, CL_alpha, Ue_D, V_Ds, WbyS_cruis, positive = false)
	
	ngust_BCs_pos = range(ngust_B_pos[end], ngust_C_pos[end], length = num_Vn)
	ngust_BCs_neg = range(ngust_B_neg[end], ngust_C_neg[end], length = num_Vn)
	ngust_CDs_neg = range(ngust_C_neg[end], ngust_D_neg[end], length = num_Vn)
	ngust_CDs_pos = range(ngust_C_pos[end], ngust_D_pos[end], length = num_Vn)
	
	V_ABs = range(V_A, V_B, length = num_Vn)
	V_BCs = range(V_B, V_C, length = num_Vn)
	
	ngust_ABs_pos = load_from_speed.(rho_SL, V_ABs, Clmax_4412, WbyS_cruis)
	ngust_VDs = range(ngust_D_pos[end], ngust_D_neg[end], length = num_Vn)
	
	# Intersection candidates
	V_nmin_gusts = range(V_Snmins[end], V_B, length = num_Vn)
	ngust_nminBs = range(n_neg[end], ngust_B_neg[end], length = num_Vn)
	ngust_BCs_neg = range(ngust_nminBs[end], ngust_C_neg[end], length = num_Vn)
	ngust_nminB2s = load_from_speed.(rho_SL, V_nmin_gusts, Clmin_4412, WbyS_cruis)
	ngust_BCs_neg2 = range(ngust_nminB2s[end], ngust_C_neg[end], length = num_Vn)
	V_B_nmin = speed_from_load(n_min, rho_SL, WbyS_cruis, Clmin_4412)
	n_neg_VB = load_from_speed(rho_SL, V_B, Clmin_4412, WbyS_cruis)
	
	# 
	ngust_B_min, ngust_B_max = ngust_B_neg[end], ngust_B_pos[end]
	ngust_C_min, ngust_C_max = ngust_C_neg[end], ngust_C_pos[end]
	ngust_D_min, ngust_D_max = ngust_D_neg[end], ngust_D_pos[end]

end

# ╔═╡ b963a72d-482d-45cc-a59d-926c64664079
begin
	## Gust loads plot
	gust = plot(
	    xlabel = "Equivalent Airspeed, V_EAS (m/s)",
	    ylabel = "Load Factor, n",
	    title  = "V-n Diagram, Gust Envelope",
	    legend = :bottomleft,
	    ylim = (min(ngust_C_min, n_min) - 0.5, max(ngust_C_max, n_max) + 0.4),
	    size = (700, 450),
	    grid = false
	)
	
	# Limits
	ns_gust = range(n_min - 3, n_max + 4, length = num_Vn)
	
	# Vertical lines
	plot!(fill(V_C, num_Vn), ns_gust,
	    line = :dash,
	    color = :gray,
	    linewidth = 1,
	    alpha = 0.5,
	    label = :none
	) # Design speed
	plot!(fill(V_MO, num_Vn), ns_gust, 
	    line = :dash,
	    color = :gray,
	    linewidth = 1,
	    alpha = 0.5,
	    label = :none
	) # Maximum operating speed
	plot!(fill(V_D, num_Vn), ns_gust, 
	    line = :dash,
	    color = :gray,
	    linewidth = 1,
	    alpha = 0.5,
	    label = :none
	) # Design driving speed
	plot!(fill(V_S, num_Vn), ns_gust,
	    line = :dash,
	    color = :gray,
	    linewidth = 1,
	    alpha = 0.5,
	    label = :none
	) # Stall speed
	plot!(fill(V_A, num_Vn), ns_gust,
	    line = :dash,
	    color = :gray,
	    linewidth = 1,
	    alpha = 0.5,
	    label = :none
	) # Corner speed
	plot!(fill(V_B, num_Vn), ns_gust,
	    line = :dash,
	    color = :gray,
	    linewidth = 1,
	    alpha = 0.5,
	    label = :none
	) # Minimum gust speed
	
	# Horizontal lines
	plot!(V_Ds, fill(n_max, num_Vn), 
	    line = :dash,
	    color = :gray,
	    linewidth = 1,
	    alpha = 0.5,
	    label = :none
	) # Maximum load factor
	plot!(V_Ds, fill(n_min, num_Vn),
	    line = :dash,
	    color = :gray,
	    linewidth = 1,
	    alpha = 0.5,
	    label = :none
	) # Minimum load factor
	plot!(V_Ds, zeros(num_Vn),
	    line = :dash,
	    color = :gray,
	    linewidth = 1,
	    alpha = 0.5,
	    label = :none
	) # Zero load factor
	plot!(V_Ds, ones(num_Vn),
	    line = :dash,
	    color = :gray,
	    linewidth = 1,
	    alpha = 0.5,
	    label = :none
	) # Unity load factor
	
	# Maneuverable envelope
	plot!(V_SAs, ns_pos_stall,
	    label= :none,
	    color = :blue
	) # Positive load factor
	plot!(V_Snmins, ns_neg_stall,
	    label= :none,
	    color = :blue
	) # Negative load factor
	
	# If minimum load factor is lesser than -1
	if n_min < -1
		plot!(V_S0s, zeros(num_Vn),
			label = :none,
			color = :blue,
		) # Stall speed negative load factor
		plot!(fill(V_n_neg_stall, num_Vn), ns_stall_min,
			label = :none,
			color = :blue,
		)
		plot!(V_Snmins, ns_neg_stall,
			label = :none,
			color = :blue
		 ) # Negative load factor
	else 
		plot!(V_Snmins, ns_neg_stall,
			label = :none,
			color = :blue
		 ) # Negative load factor
	end
	
	plot!(V_nminCs, n_C_min,
	    label = :none,
	    color = :blue
	) # Minimum load factor
	plot!(V_nmaxDs, fill(n_max, num_Vn),
	    label = :none,
	    color = :blue
	) # Maximum load factor
	
	plot!(fill(V_D, num_Vn), range(0, n_max, length = num_Vn),
	    label = :none,
	    color = :blue
	) # Maximum operating speed
	plot!(V_CDs, n_CDs,
	    label = :none,
	    color = :blue
	) # Linearly increasing from VC to VD
	
	plot!(fill(V_S, num_Vn), ns_stall_max,
	    label = :none,
	    color = :blue
	) # Stall speed
	
	# Gust envelope
	plot!(V_Bs, ngust_B_pos,
	    color = :red, 
	    line = :dot, 
	    linewidth = 1.5,
	    alpha = 0.5,
	    label = "n_gust, B"
	) # Positive gust, B
	plot!(V_Bs, ngust_B_neg,
	    color = :red, 
	    line = :dot, 
	    linewidth = 1.5,
	    alpha = 0.5,
	    label = :none
	) # Negative gust, B 
	
	plot!(V_Cs, ngust_C_pos,
	    color = :green, 
	    line = :dot, 
	    linewidth = 1.5,
	    alpha = 0.5,
	    label = "n_gust, C"
	) # Positive gust, C
	
	plot!(V_Cs, ngust_C_neg,
	    color = :green, 
	    line = :dot, 
	    linewidth = 1.5,
	    alpha = 0.5,
	    label = :none
	) # Negative gust, C
	
	plot!(V_Ds, ngust_D_pos,
	    color = :cornflowerblue,
	    line = :dot,
	    linewidth = 1.5,
	    alpha = 0.5,
	    label =  "n_gust, D"
	) # Positive gust, D
	plot!(V_Ds, ngust_D_neg,
	    color = :cornflowerblue,
	    line = :dot,
	    linewidth = 1.5,
	    alpha = 0.5,
	    label = :none
	) # Negative gust, D
	
	# Reds 
	plot!(V_BCs, ngust_BCs_pos,
	    color = :red,
	    label = :none
	) # Positive load factors from VB to VC
	
	plot!(V_CDs, ngust_CDs_pos,
	    color = :red,
	    label = :none
	) # Positive load factors from VC to VD
	plot!(V_CDs, ngust_CDs_neg,
	    color = :red,
	    label = :none
	) # Negative load factors from VC to VD
	
	plot!(fill(V_D, num_Vn), ngust_VDs,
	    color = :red,
	    label = :none
	) # Load factors on VD
	
	if V_B > V_A
	    plot!(V_ABs, ngust_ABs_pos,
	    color = :red,
	    label = :none
	    ) # Positive load factors from VA to VB
	end
	
	if V_B < V_B_nmin
	    plot!(V_BCs, ngust_BCs_neg,
	    color = :red,
	    label = :none
	    ) # Negative load factors from VB to VC
	else 
	    if n_neg_VB > ngust_B_neg[end] # If the minimum n is the VB gust load
		    plot!(V_nmin_gusts, ngust_nminB2s,
		        color = :red,
		        label = :none
		        ) # Negative load factors from n_neg to VB
		    plot!(V_BCs, ngust_BCs_neg2,
		        color = :red,
		        label = :none
		        ) # Negative load factors from VB to VC
		else # If the minimum n is the minimum negative load factor
		    plot!(V_BCs, ngust_BCs_neg,
		        color = :red,
		        label = :none
		        ) # Negative load factors from VB to VC
		end
	end
	
	# Vertices
	scatter!(vertices_1[:,1] , vertices_1[:,2], 
	    label = "", 
	    mc = :blue, 
	    alpha = 0.5,
	    ms = 2,
	)
	
	eps2 = 0.2 # Offset factor for annotations
	annotate!(vertices_1[:,1], vertices_1[:,2] .+ eps2, vertices_1[:,3])
	
	vertices_2 = [ 
	    V_B ngust_B_max "VB" ; 
	    V_C ngust_C_max "VC'" ; 
	    V_D ngust_D_max "VD'" 
	]
	
	scatter!(vertices_2[:,1], vertices_2[:,2], 
	    label = "", 
	    mc = :red, 
	    alpha = 0.5,
	    ms = 2,
	)
	
	eps3 = 0.2
	annotate!(vertices_2[:,1] .- 5eps, vertices_2[:,2] .+ 1.1eps3, vertices_2[:,3])
end

# ╔═╡ 5e931cff-8eae-4c9e-8aab-5f608ad466b5
md" # Aerodynamic Refinement"

# ╔═╡ bbc30df1-290a-4b30-8802-25e16aa4da2c
md" ## Trim Drag"

# ╔═╡ 5f856f0d-4e84-4fad-b95c-101e84b16714
e_ht = 2/(2-AR_h+(4+(AR_h^2)*(1+(tan(35))^2))^0.5)

# ╔═╡ c337e766-0970-4007-903d-927c8aec3116
Cd_trim(C_L_ac,CL_Wing) = (1/(pi*e_ht*AR_h))*((C_L_ac - CL_Wing)^2)*(S_ref/(S_ht*2))

# ╔═╡ 921b4df8-de25-4026-83af-cba3abf6dce3
C_L_acs = -1.5:0.1:1.8

# ╔═╡ ce308b80-c0ad-4aa9-b0fd-f4b346371bc5
plot(C_L_acs, Cd_trim.(C_L_acs,0.781813), label = "CD_Trim")


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AeroFuse = "477c59f4-51f5-487f-bf1e-8db39645b227"
CalculusWithJulia = "a2e0e22d-7d4c-5312-9169-8b992201a882"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Polynomials = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
PrettyTables = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
Xfoil = "19641d66-a62d-11e8-2441-8f57a969a9c4"

[compat]
AeroFuse = "~0.4.10"
CalculusWithJulia = "~0.1.4"
DataFrames = "~1.6.1"
Plots = "~1.39.0"
PlutoUI = "~0.7.57"
Polynomials = "~4.0.6"
PrettyTables = "~2.3.1"
Xfoil = "~0.5.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.2"
manifest_format = "2.0"
project_hash = "08bec3763030b86bc05e285e5a8d8ea29cf90ca2"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "c278dfab760520b8bb7e9511b968bf4ba38b7acc"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.3"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "MacroTools", "Test"]
git-tree-sha1 = "cb96992f1bec110ad211b7e410e57ddf7944c16f"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.35"

    [deps.Accessors.extensions]
    AccessorsAxisKeysExt = "AxisKeys"
    AccessorsIntervalSetsExt = "IntervalSets"
    AccessorsStaticArraysExt = "StaticArrays"
    AccessorsStructArraysExt = "StructArrays"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    Requires = "ae029012-a4dd-5104-9daa-d747884805df"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cde29ddf7e5726c9fb511f340244ea3481267608"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AeroFuse]]
deps = ["Accessors", "ComponentArrays", "CoordinateTransformations", "DelimitedFiles", "DiffResults", "ForwardDiff", "Interpolations", "LabelledArrays", "LinearAlgebra", "MacroTools", "PrettyTables", "RecipesBase", "Roots", "Rotations", "SparseArrays", "SplitApplyCombine", "StaticArrays", "Statistics", "StatsBase", "StructArrays", "Test", "TimerOutputs"]
git-tree-sha1 = "3d24e1869cb0e1b3fe4160da7f6fd495da38e493"
uuid = "477c59f4-51f5-487f-bf1e-8db39645b227"
version = "0.4.10"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "Requires", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "c5aeb516a84459e0318a02507d2261edad97eb75"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.7.1"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9e2a6b69137e6969bab0152632dcb3bc108c8bdd"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+1"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.CalculusWithJulia]]
deps = ["Base64", "Contour", "ForwardDiff", "HCubature", "IntervalSets", "JSON", "LinearAlgebra", "PlotUtils", "Random", "RecipesBase", "Reexport", "Requires", "Roots", "SpecialFunctions", "SplitApplyCombine", "Test"]
git-tree-sha1 = "df0608635021120c3d2e19a70edbb6506549fe14"
uuid = "a2e0e22d-7d4c-5312-9169-8b992201a882"
version = "0.1.4"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "ad25e7d21ce10e01de973cdc68ad0f850a953c52"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.21.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "59939d8a997469ee05c4b4944560a820f9ba0d73"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.4"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CommonSolve]]
git-tree-sha1 = "0eee5eb66b1cf62cd6ad1b460238e60e4b09400c"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.4"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "d2c021fbdde94f6cdaa799639adfeeaa17fd67f5"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.13.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.0+0"

[[deps.ComponentArrays]]
deps = ["ArrayInterface", "ChainRulesCore", "ForwardDiff", "Functors", "LinearAlgebra", "Requires", "StaticArrayInterface"]
git-tree-sha1 = "00380a5de40736c634b867069347b721ca311673"
uuid = "b0b7db55-cfe3-40fc-9ded-d10e2dbeff66"
version = "0.13.15"

    [deps.ComponentArrays.extensions]
    ComponentArraysConstructionBaseExt = "ConstructionBase"
    ComponentArraysGPUArraysExt = "GPUArrays"
    ComponentArraysRecursiveArrayToolsExt = "RecursiveArrayTools"
    ComponentArraysReverseDiffExt = "ReverseDiff"
    ComponentArraysSciMLBaseExt = "SciMLBase"
    ComponentArraysStaticArraysExt = "StaticArrays"

    [deps.ComponentArrays.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    GPUArrays = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
    RecursiveArrayTools = "731186ca-8d62-57ce-b412-fbd966d074cd"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SciMLBase = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "9c4708e3ed2b799e6124b5673a712dda0b596a9b"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.3.1"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"
weakdeps = ["IntervalSets", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "f9d7112bfff8a19a3a4ea4e03a8e6a91fe8456bf"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.3"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "ac67408d9ddf207de5cfa9a97e114352430f01ed"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.16"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "573c92ef22ee0783bfaa4007c732b044c791bc6d"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.4.1"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.ExprTools]]
git-tree-sha1 = "27415f162e6028e81c72b82ef756bf321213b6ec"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.10"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d8db6a5a2fe1381c1ea4ef2cab7c69c2de7f9ea0"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.1+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Functors]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "166c544477f97bbadc7179ede1c1868e0e9b426b"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.4.7"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "ff38ba61beff76b8f4acad8ab0c97ef73bb670cb"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.9+0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "2d6ca471a6c7b536127afccfa7564b5b39227fe0"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.5"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "27442171f28c952804dede8ff72828a96f2bfc1f"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.10"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "025d171a2847f616becc0f84c8dc62fe18f0f6dd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.10+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "e94c92c7bf4819685eb80186d51c43e71d4afa17"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.76.5+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HCubature]]
deps = ["Combinatorics", "DataStructures", "LinearAlgebra", "QuadGK", "StaticArrays"]
git-tree-sha1 = "a7367c00dabf3adab3ec7498c8ce102e984293f3"
uuid = "19dc6840-f33b-545b-b366-655c7e3ffd49"
version = "1.5.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "ac7b73d562b8f4287c3b67b4c66a5395a19c1ae8"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "721ec2cf720536ad005cb38f50dbba7b02419a15"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.7"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"
weakdeps = ["Random", "RecipesBase", "Statistics"]

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "68772f49f54b479fa88ace904f6127f0a3bb2e46"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.12"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "a53ebe394b71470c7f97c2e7e170d51df21b17af"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.7"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "60b1194df0a3298f460063de985eae7b01bc011a"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.1+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d986ce2d884d49126836ea94ed5bfb0f12679713"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.LabelledArrays]]
deps = ["ArrayInterface", "ChainRulesCore", "ForwardDiff", "LinearAlgebra", "MacroTools", "PreallocationTools", "RecursiveArrayTools", "StaticArrays"]
git-tree-sha1 = "d1f981fba6eb3ec393eede4821bca3f2b7592cd4"
uuid = "2ee39098-c373-598a-b85f-a56591580800"
version = "1.15.1"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "f428ae552340899a935973270b8d98e5a31c49fe"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.1"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "2da088d113af58221c52828a80378e16be7d037a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.5.1+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "18144f3e9cbe9b15b070288eef858f71b291ce37"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.27"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
git-tree-sha1 = "6a731f2b5c03157418a20c12195eb4b74c8f8621"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.13.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "60e3045590bd104a16fefb12836c00c0ef8c7f8c"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.13+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "64779bc4c9784fee475689a1752ef4d5747c5e87"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.42.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "862942baf5663da528f66d24996eb6da85218e76"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.0"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "ccee59c6e48e6f2edf8a5b64dc817b6729f99eb5"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.39.0"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "a6783c887ca59ce7e97ed630b74ca1f10aefb74d"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.57"

[[deps.Polynomials]]
deps = ["LinearAlgebra", "RecipesBase", "Setfield", "SparseArrays"]
git-tree-sha1 = "a9c7a523d5ed375be3983db190f6a5874ae9286d"
uuid = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
version = "4.0.6"

    [deps.Polynomials.extensions]
    PolynomialsChainRulesCoreExt = "ChainRulesCore"
    PolynomialsFFTWExt = "FFTW"
    PolynomialsMakieCoreExt = "MakieCore"
    PolynomialsMutableArithmeticsExt = "MutableArithmetics"

    [deps.Polynomials.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    FFTW = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
    MakieCore = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
    MutableArithmetics = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PreallocationTools]]
deps = ["Adapt", "ArrayInterface", "ForwardDiff", "Requires"]
git-tree-sha1 = "01ac95fca7daabe77a9cb705862bd87016af9ddb"
uuid = "d236fae5-4411-538c-8e31-a6e3d9e00b46"
version = "0.4.13"

    [deps.PreallocationTools.extensions]
    PreallocationToolsReverseDiffExt = "ReverseDiff"

    [deps.PreallocationTools.weakdeps]
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "88b895d13d53b5577fd53379d913b9ab9ac82660"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "37b7bb7aabf9a085e0044307e1717436117f2b3b"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.5.3+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9b23c31e76e333e6fb4c1595ae6afa74966a729e"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.9.4"

[[deps.Quaternions]]
deps = ["LinearAlgebra", "Random", "RealDot"]
git-tree-sha1 = "994cc27cdacca10e68feb291673ec3a76aa2fae9"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.7.6"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.RecursiveArrayTools]]
deps = ["Adapt", "ArrayInterface", "DocStringExtensions", "GPUArraysCore", "IteratorInterfaceExtensions", "LinearAlgebra", "RecipesBase", "Requires", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables"]
git-tree-sha1 = "d7087c013e8a496ff396bae843b1e16d9a30ede8"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "2.38.10"

    [deps.RecursiveArrayTools.extensions]
    RecursiveArrayToolsMeasurementsExt = "Measurements"
    RecursiveArrayToolsMonteCarloMeasurementsExt = "MonteCarloMeasurements"
    RecursiveArrayToolsTrackerExt = "Tracker"
    RecursiveArrayToolsZygoteExt = "Zygote"

    [deps.RecursiveArrayTools.weakdeps]
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    MonteCarloMeasurements = "0987c9cc-fe09-11e8-30f0-b96dd679fdca"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Roots]]
deps = ["Accessors", "ChainRulesCore", "CommonSolve", "Printf"]
git-tree-sha1 = "754acd3031a9f2eaf6632ba4850b1c01fe4460c1"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.1.2"

    [deps.Roots.extensions]
    RootsForwardDiffExt = "ForwardDiff"
    RootsIntervalRootFindingExt = "IntervalRootFinding"
    RootsSymPyExt = "SymPy"
    RootsSymPyPythonCallExt = "SymPyPythonCall"

    [deps.Roots.weakdeps]
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalRootFinding = "d2bf35a9-74e0-55ec-b149-d360ff49b807"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"

[[deps.Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays"]
git-tree-sha1 = "2a0a5d8569f481ff8840e3b7c84bbf188db6a3fe"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.7.0"
weakdeps = ["RecipesBase"]

    [deps.Rotations.extensions]
    RotationsRecipesBaseExt = "RecipesBase"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "0e7508ff27ba32f26cd459474ca2ede1bc10991f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.SplitApplyCombine]]
deps = ["Dictionaries", "Indexing"]
git-tree-sha1 = "c06d695d51cfb2187e6848e98d6252df9101c588"
uuid = "03a91e81-4c3e-53e1-a0a4-9c0c8f19dd66"
version = "1.2.3"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "b366eb1eb68075745777d80861c6706c33f588ae"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.8.9"

[[deps.StaticArrayInterface]]
deps = ["ArrayInterface", "Compat", "IfElse", "LinearAlgebra", "PrecompileTools", "Requires", "SparseArrays", "Static", "SuiteSparse"]
git-tree-sha1 = "5d66818a39bb04bf328e92bc933ec5b4ee88e436"
uuid = "0d7ed370-da01-4f52-bd93-41d350b8b718"
version = "1.5.0"
weakdeps = ["OffsetArrays", "StaticArrays"]

    [deps.StaticArrayInterface.extensions]
    StaticArrayInterfaceOffsetArraysExt = "OffsetArrays"
    StaticArrayInterfaceStaticArraysExt = "StaticArrays"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "7b0e9c14c624e435076d19aea1e5cbdec2b9ca37"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.2"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.StructArrays]]
deps = ["Adapt", "ConstructionBase", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "1b0b1205a56dc288b71b1961d48e351520702e24"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.17"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.SymbolicIndexingInterface]]
deps = ["DocStringExtensions"]
git-tree-sha1 = "f8ab052bfcbdb9b48fad2c80c873aa0d0344dfe5"
uuid = "2efcf032-c050-4f8e-a9bb-153293bab1f5"
version = "0.2.2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f548a9e9c490030e545f72074a41edfd0e5bcdd7"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.23"

[[deps.TranscodingStreams]]
git-tree-sha1 = "54194d92959d8ebaa8e26227dbe3cdefcdcd594f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.3"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "3c793be6df9dd77a0cf49d80984ef9ff996948fa"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.19.0"
weakdeps = ["ConstructionBase", "InverseFunctions"]

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "e2d817cc500e960fdbafcf988ac8436ba3208bfd"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.3"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "93f43ab61b16ddfb2fd3bb13b3ce241cafb0e6c9"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.31.0+0"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "5f24e158cf4cee437052371455fe361f526da062"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.6"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "801cbe47eae69adc50f36c3caec4758d2650741b"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.12.2+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ac88fb95ae6447c8dda6a5503f3bafd496ae8632"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.4.6+0"

[[deps.Xfoil]]
deps = ["Printf", "xfoil_light_jll"]
git-tree-sha1 = "752ff27037088b747d3138c828ffc0968d2e7766"
uuid = "19641d66-a62d-11e8-2441-8f57a969a9c4"
version = "0.5.0"

[[deps.Xorg_libICE_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "e5becd4411063bdcac16be8b66fc2f9f6f1e8fe5"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.0.10+1"

[[deps.Xorg_libSM_jll]]
deps = ["Libdl", "Pkg", "Xorg_libICE_jll"]
git-tree-sha1 = "4a9d9e4c180e1e8119b5ffc224a7b59d3a7f7e18"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.3+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "b4bfde5d5b652e22b9c790ad00af08b6d042b97d"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.15.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a68c9655fbe6dfcab3d972808f1aafec151ce3f8"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.43.0+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3516a5630f741c9eecb3720b1ec9d8edc3ecc033"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "873b4f805771d3e4bafe63af759a26ea8ca84d14"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.42+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xfoil_light_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "1ebea4f4577b2aa95d4151e11ed6210341e76f62"
uuid = "70cc596b-f351-5640-b155-76ddf0ff62ca"
version = "0.2.1+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╟─64afbf40-e7aa-11ee-282e-579216dd0e65
# ╠═aef2f062-19de-4cbc-b6cf-01d93c767d4a
# ╠═a5c3f51f-339d-4039-83d1-8eec15ee3790
# ╠═5c315eca-2a67-4d43-b294-dc2d7996f434
# ╟─1bc89999-2ada-47d7-89a9-4314eb09c1c2
# ╟─e7c1ad3b-33f2-45d5-8d66-7c99adc53d25
# ╟─39ffd4ca-7905-4276-b0b6-20ae1c530097
# ╟─ab589d30-531a-4f49-927c-739335fe3a7b
# ╟─6d1a05b0-9128-4e3c-887c-c4d43c57efac
# ╠═72747e12-4ab5-4090-8a51-b8747741b07e
# ╟─6932192d-758a-4133-956d-9c8f4fb3d306
# ╟─8cb6b156-1b2c-4a82-8d53-38a451ca04ed
# ╟─81a0d772-9cc1-40ef-b31c-eb720f82f568
# ╠═32115fbc-2ec8-40f9-bdb8-3826b1c969cb
# ╠═20b4bcb6-890e-4166-ae3b-d382a2a391f2
# ╠═22d5bccc-6fcc-44c4-964b-a034025f84d1
# ╠═5ceca88b-642d-4b58-b680-b1d9e1365fb1
# ╠═0cd381ea-ca89-4473-8d06-cffc47d33314
# ╟─e3b80ea2-d8da-4a12-84d5-e7dcc7f98880
# ╠═ea51288e-4199-4fda-b8ed-b9eacb1775b7
# ╠═1234b5e1-96e0-4c00-841c-44ba33f21caf
# ╠═7a4cd613-6110-4483-891c-4a3ff7052052
# ╟─470b1aa4-689b-47f4-8bad-3fbb6006f117
# ╠═f62e35b1-a487-4fd8-969d-184490572a22
# ╠═2f3521f7-438d-4d2f-99de-38f5f527f8a4
# ╠═a4fa5e98-9ed2-4724-b3e3-33d5add0077c
# ╠═ccd459b2-39e0-4e25-94a4-1972705136f5
# ╠═ae3b7816-0968-4610-a207-50c893a7b0fe
# ╠═78a67dff-0719-4fc2-a1dd-4097fc74d699
# ╟─fbe1fe14-d209-4a6c-b82f-2d85faacaf0a
# ╠═5ee13179-dd5e-46e6-8b14-2025a15b7f01
# ╠═fc2bc97e-fd0c-4893-b09d-ef8330abe5b5
# ╠═a178cee5-55fe-4697-af21-ce3490e9dcb3
# ╠═81863466-3919-4dc2-80cf-1d3011170537
# ╠═a4d8bf46-6d5c-40d8-a68a-665ea663b5bd
# ╠═3cc38fd3-08a9-47e0-9f26-4801c27b465e
# ╟─69665064-c6f7-4638-a635-cff09e391561
# ╠═cc48cfcb-06e2-4956-b7cb-fc7da79e3b1d
# ╠═d7a90ac7-afaf-4489-bdfe-2a8df4573520
# ╠═b052907b-90a1-455c-9a2b-ee5d60ec94b5
# ╠═e5fd76c8-5fbe-4979-a54b-8003aeab4f14
# ╟─741496ed-94ab-48f9-a625-6f94c8b276f8
# ╟─352536d4-805b-4083-856b-ca5ddb8138ea
# ╟─32709885-a25e-4195-855b-3f21b28d9c7a
# ╠═32eb82e3-6c50-4c57-8b07-edefe7dd3f74
# ╠═e0943d16-1c6e-41e7-9f8b-6969ba70ea57
# ╠═71be7d65-bf13-4f4c-972a-ed269dac0605
# ╠═d90ab36e-95ca-4de1-b9f6-a2edf75b4387
# ╠═2a1e4c38-8763-460b-a343-39a74e4777fe
# ╟─e67e0ab1-316f-4da9-9a7f-d86f6eb6721a
# ╠═923836cf-2ff3-4055-b773-304eb7a7148b
# ╠═0908bf03-986f-49a5-b606-04f0736a92ae
# ╠═723789d3-7289-4d8f-88dd-320ff28f5711
# ╠═4d23c2b9-55fb-430f-989d-3657476a77bc
# ╠═5cede6db-12db-4a2d-989f-886fea72e08c
# ╠═59bd07fd-f430-4e54-91cb-38507a96fad5
# ╠═ee9bfa60-2883-4a7a-8900-f4d4a05408e8
# ╠═3b1aa5f5-91fe-4bca-8b9d-0e1f9a4fb0d9
# ╠═e677c58d-bae9-4716-9088-6279e45ca478
# ╠═0b409b30-cb9c-4500-8099-6e863ee34dd7
# ╠═5b1c0694-e148-4886-a3db-7a7db1c2d89f
# ╠═819934df-9768-472e-a820-7ebdabd70601
# ╟─db2054e7-89ba-4107-b85f-ca6294e3d683
# ╠═c054c67d-b358-4c0d-9f39-d6894d1e1073
# ╟─83123058-65dc-4177-9102-8f53f49ad6ac
# ╟─f6d6e4b4-e371-4fc1-bdb1-07834094b131
# ╟─bc078e40-91ae-49f6-9136-0a89c3d99ed2
# ╟─824adc9c-ee04-4125-9406-d53093cac092
# ╠═ae4797ca-7d3a-4134-8154-5b50cd9a7851
# ╠═6c0369c2-947e-4110-af30-5741834ad178
# ╠═e798a74a-48b0-4651-9ba4-90055e9ca5bb
# ╟─5db9b815-ea70-4e2d-b7b7-e9eee677c6e3
# ╟─68954d61-bdcb-41dc-8ea8-93112d8cf240
# ╠═4ccb3b35-9da3-4abf-bf8b-67493cdcab3c
# ╟─89989cf6-a764-4e88-bd1c-865e2b447a00
# ╟─e1a52f37-988c-44fa-a84f-b7ebb5b06b41
# ╟─85ddc1ce-c661-46f5-9e2a-46171bfa40c0
# ╠═fe703a8b-5e4b-4e34-9799-36e549b5c36e
# ╟─f1f3f858-36b7-4c0e-bbec-a568d784a938
# ╠═15cbf64f-4c23-4062-9a56-204f2e9f6a88
# ╟─9e89ce7e-7f9a-4bb1-bf78-f04d3cee4c94
# ╠═cf9f2f74-1f35-4e84-8641-e000c8a4bbbd
# ╠═271bae14-4da8-4cd9-b68c-7321c14f8fe7
# ╠═d6e10fea-3ed7-408e-9940-06d951031fcf
# ╠═7a3d8afc-0813-441b-90c0-f22642f145ec
# ╟─111eaa73-1d65-4692-823a-31ecc12b66dd
# ╟─c0a17500-521b-4728-84d3-74c1cf149249
# ╠═df354ce7-e6f6-47ab-baba-2132412c7c79
# ╟─59270c9e-b34e-4527-a0bd-5590bb5c7612
# ╠═b2b578d6-a078-4506-a812-5782255c78ca
# ╟─685758b9-fbe5-4cd1-99ba-227b025ace6e
# ╠═a77e6278-68f6-494c-9010-9b07a7c471bc
# ╟─3170a1b9-bf5e-42b4-9521-f7193bb5fb6c
# ╟─6ecae78a-5967-4e16-b932-6ec649624b96
# ╠═1efaccbd-abb6-4637-847b-cfad9fe8b413
# ╠═c83b9044-c5cf-4308-a3a1-4502c11385e0
# ╠═f27aba2f-10d2-4cc5-b86d-228abbb61cc0
# ╠═5520b2f9-cbdd-46ef-8200-76828bee4661
# ╟─e1776759-bd25-48d5-9753-7efbb8f81b1f
# ╟─a4bf5b5c-d4b7-4736-ad8d-b4a46a4e16f2
# ╟─d75674aa-23ad-4a3d-b936-1a8a613035f7
# ╠═6b7ed88d-a9c0-4a17-9816-6244c34065c8
# ╠═ea4a050e-2029-4c74-a631-175622fcc308
# ╠═f46d9a0a-ecc6-45fa-82fa-bd7c029d3c6a
# ╠═4a0ec6ac-5b7b-4ab1-bfd8-e267f54cdee1
# ╠═e61bdfbc-4dfe-4ee9-9c43-e4f056e18131
# ╠═4802362f-feb1-41b7-915d-3efec537b1b1
# ╠═b18d94d2-baa3-46c4-adc0-cdf43630aa3d
# ╠═59839dae-8a32-42cb-9d8c-fd019b65c15b
# ╟─ccaae600-470a-4502-ae9c-05abe854d2fa
# ╠═86306938-c822-4dcc-914a-cebbccd97387
# ╠═800abc8e-e07e-465e-a033-89f504d13f9f
# ╠═af980183-f0d5-457c-bb6d-1204654cc306
# ╠═dd3b0468-e323-4d88-a209-f9f85c261956
# ╟─88a5a5ab-c229-4a0c-9043-9b0d84879d79
# ╟─11243aaf-517e-4313-8222-4866f2249d42
# ╟─6396f027-3e40-4837-82c1-f3ce01aa6d19
# ╠═2d9dc8f3-326a-436f-916d-02f8483a815f
# ╠═e9a58566-aa42-41de-ba6f-8bc5bea5e8a7
# ╠═45dde11f-b878-4ce3-88c7-9f3fdd7c109f
# ╠═52ae46d9-576e-4224-bfe4-04daa6990c76
# ╠═9ba45a64-57aa-4841-b7b1-d0a42ac8a963
# ╟─e03fe34a-d08b-41fd-b7f8-19934fe838be
# ╠═a53bc6f4-9b90-428f-90db-3cf1265abccd
# ╠═cf6282e5-5130-45ee-8161-9924e76def2d
# ╠═7e5c95b8-824e-4c24-ae7d-51a64c40258a
# ╠═4850ade4-87b2-4cfb-8e75-b28363a3bb6e
# ╠═936fa626-d99a-4d37-910b-dc549bc1caeb
# ╠═8f882e5f-2736-4140-b984-0f8b1667963a
# ╟─9b3c70a9-cd79-45d9-a7aa-9eed24d4b49f
# ╠═c3e0bbc2-0070-4fed-b03b-dbee8259345a
# ╠═c0cc4d83-7522-4816-88de-2cd77a5b8893
# ╠═9c8505e4-e321-4003-85c5-95145094a487
# ╟─7b4223db-197f-4796-ace1-b32bf40dac28
# ╟─eb6d8e61-83ce-46a4-8726-0b56a73a44bc
# ╟─6a82433e-4c81-4a27-9bd2-fa8bd957c28d
# ╠═a56deffb-315b-4031-8086-23ea9e8954c9
# ╠═88bb05ff-ddc8-43f4-8835-ec121f182c57
# ╟─883f5781-e694-441a-9d08-d3f2de47ee06
# ╠═1bea727e-8b43-4c50-a38c-805770100fc3
# ╠═e59d901b-4b72-4dc5-a8e5-996592216ffc
# ╟─2930785a-78ea-481d-a1db-d2dd3d25b70f
# ╠═f1552f2d-8f0c-4065-9f47-e5349cbe25ca
# ╟─c1667ec4-142e-4d49-ad6b-88c8ef19d51b
# ╠═47be4dfd-bc90-4711-966f-c20aa3c6f2a8
# ╟─9fc355f8-51ed-4d5e-af1e-79571afc76fb
# ╠═4041daef-d131-4778-aebc-ee8608dcdc68
# ╠═88c8eb6a-34cf-4a9a-b67f-e8c5fda008de
# ╠═e4e6425d-bf3c-4bf2-948a-ecc7aa82c1eb
# ╠═02b2c8d3-e68d-4959-a32f-d99d31faf237
# ╠═e637be1f-413d-4d5f-9893-509c715cd775
# ╠═f132d897-962e-4f48-83dc-009e85a003bf
# ╟─ddb03780-ed64-4adf-9579-aebc3df5e649
# ╠═ef7ef832-679a-42b5-b0b2-350bc059f12f
# ╟─9cda2c2a-0e00-4864-a62b-873826792191
# ╠═31e5f979-71f0-4fa0-b053-5dbea5330512
# ╠═c8f0fed9-596a-4b31-bf0e-e0b3c27614dc
# ╠═d64d5978-0d33-46c4-a99e-b1b6efa18724
# ╠═e66b3643-b2db-4bf5-868b-7ea1832efa29
# ╠═61ab67ec-85da-482b-95f7-14d94a4a7b74
# ╟─32db9655-2181-4b22-b93a-40a13b556763
# ╠═8386b75b-090c-4ceb-8d7d-e92cab8461fc
# ╟─6c6fa635-8119-42e0-8081-704129f7a56a
# ╟─ab4c7dfc-ae1b-4d31-8c0b-4ff1edcf1b57
# ╠═1b87233d-db46-4bff-bbaf-8a40a0e6b709
# ╟─abea4f86-9abc-4217-bbbd-d09d1b5c8601
# ╠═d3b42a56-6a67-4d2e-bbab-82a08e38dde8
# ╠═7f5d9332-b3c4-4bdc-b51b-a0e92452069e
# ╟─acbe6151-c58e-4c1a-971e-48200927a4fa
# ╟─0caf1416-ffd8-4b24-be9b-28ef19622a8c
# ╠═ea5f4c42-1636-4cbc-be31-35d82c21bc22
# ╠═88452ce5-fffd-4958-b628-09958d6d230d
# ╠═09470d80-35ac-4546-917f-bd40c02a1583
# ╠═3920101e-f800-41da-b8c6-6d93f2256dfd
# ╠═30888073-67bf-4bdc-9e99-422a0823849a
# ╠═15c94dac-9566-4b11-8d2b-19d107da910b
# ╠═98bee0d1-c103-4c73-924d-29e960aa7107
# ╠═60743406-d883-4010-ad4a-add945bec32e
# ╠═c4f8a09c-139c-49bb-8e53-109ed671aaef
# ╠═a0bdb17c-bc1e-4bc0-95b4-8b62369050ad
# ╠═3661c200-20a8-433b-bc5d-b4b154dc387c
# ╟─d766cb09-9fd0-4008-8bb5-2a2d9b7bddb1
# ╠═a5772edc-854c-4b21-b370-bde1b34f3429
# ╠═d1430272-9e20-4e5e-b531-740a450eed80
# ╠═e7736066-1396-411f-8792-c3e1a01d4437
# ╠═6b425df7-6c44-4dc8-be2e-290070769317
# ╠═cc6b6b53-5627-411d-8347-32b3a037dd82
# ╟─d12827b6-b106-437a-b230-d0c65dbba7f6
# ╟─4edc4225-4b7f-4c79-9429-428e731a40dc
# ╠═570b4126-0d8a-4603-ac15-b47dd31840da
# ╠═831b1d45-feac-415d-bbb3-c3ef4eef6f09
# ╠═562b03e6-750d-4bd2-9c7f-c87a5dc2c44e
# ╠═f1aede87-bab1-4d42-8489-15c89b7b2a37
# ╠═86ecb3b2-5b8a-4f44-8eec-e2588a929dbd
# ╠═588dc9dd-0a56-40c4-bdea-6a1844732463
# ╠═cdc15a1a-1c26-4e7a-9805-224b215d8a2f
# ╟─eb936afd-9a4d-45af-818f-421e22545bcc
# ╠═5b754e48-cfe3-4c27-afec-75911337ee92
# ╠═90bde345-2ea6-40e7-b080-0e2ee95f2e2c
# ╠═578f09ae-c98f-4cfe-b9fa-57c210eebd2e
# ╠═98819907-a0a6-439b-bfee-0d82d0187e0c
# ╠═10bab11b-8772-4f63-ac39-5e2d7ee15fbe
# ╠═2743c42c-249d-4b70-b7cb-02e371a79c0a
# ╠═6cc59cae-2e12-4bf4-8e2d-751f0d47eab0
# ╠═d5f23980-84d1-4308-bdc8-3ad685e330cf
# ╠═3433a47f-bb2e-42e0-a258-dca84453f63b
# ╠═83cc69e5-adb0-4beb-b515-8fd662d073d5
# ╠═22aa49ea-ee11-493b-9a15-266785bf48ed
# ╠═2b980c26-6429-467b-b57f-19c785c3f19b
# ╠═ab8d469d-ce31-48a2-b3c6-96393b950381
# ╠═2711abe2-b740-4871-890e-e3c1d0bc1dfc
# ╠═56926f5f-32fc-4798-aa95-0a78fe126eb6
# ╠═3a50f23f-d5fc-49e0-a5c0-ab52b098ff02
# ╠═7e1321a2-b197-4c60-a6fc-03e533a5504c
# ╠═ba2f2e00-aa5f-4478-9951-c7a16a3834f7
# ╠═7e453270-1320-458d-a1e7-921d86d0e750
# ╠═4cbf0b7e-7886-41b2-bc62-f54f601fa9f1
# ╠═0fe19e3b-36a8-4d17-b89b-c04419c7fbe6
# ╠═8774bd8f-91eb-4c86-9ba9-62fae14188f9
# ╠═39c0bba6-cd04-483a-baca-e4c975db261a
# ╟─544df64c-bef7-4125-9b50-4937589832c2
# ╠═82b62e79-60de-4829-890b-dc9e6a0d018c
# ╟─a7f9e034-79c6-4a00-a3ba-502b3687ed00
# ╠═b9062352-3b94-44e3-8f13-d6ad9e6c22c7
# ╠═1588ec8c-9040-4873-81b1-92cbd0ab9f09
# ╠═88c42c90-0bc5-4c2b-aaff-31b8160d89c1
# ╠═6fcfc773-0a43-45a8-b777-ea0e542ff015
# ╟─50773fa5-b0c2-430b-9c13-3031bcda5d52
# ╠═fee8e83b-2670-4887-832c-c7f00fde522e
# ╠═95b77ea6-3fa9-4735-b909-20d50509db32
# ╠═5d767246-ca69-4318-b334-67065b719f83
# ╠═c2b76ab7-121b-4020-8d44-854769835f5e
# ╠═00893fb7-6538-45d8-a439-79cc4bbcf939
# ╠═19336d97-8355-4dc5-815d-ae149886dec1
# ╠═f97bf075-4109-4ad2-93a1-238707fba1e6
# ╠═e905c082-b8ee-4fbb-8430-5b23cc66cd0f
# ╠═2d3f7c94-da57-4a30-a6a8-74f720ecfa79
# ╠═c33b0b8c-06e3-48e3-8ad5-f509bd81775c
# ╟─cbc899eb-8280-4e2d-bec3-6db70449850b
# ╟─55dfb095-9059-438d-a7ba-4feed9985bfd
# ╠═92d751f8-1760-4163-aad1-f7ba638522a3
# ╠═95827391-53cb-4583-9b68-93db854e7596
# ╠═ddc77cb3-52b0-4787-b752-ed500f42b8f0
# ╟─0f849781-eead-468c-af84-8488c02d14e9
# ╟─0cfa4648-5d17-45ab-a77a-9233831562d5
# ╠═a1e6baf2-6bf6-40cd-b315-ecc4dc42b7a7
# ╠═158315ef-c783-4cf0-b551-9eac22775768
# ╠═9ccb66fd-8b49-4c01-8e8c-09688030443a
# ╠═4f72fdd6-10f3-4768-aee6-5c6bff8ffc93
# ╠═ea2ac373-e1c9-420f-9dfa-4c25b7724fa4
# ╠═68868d79-2553-4a0f-99d2-876662adb8fe
# ╠═93ae7550-2df0-425b-8e5e-f1cf98e48565
# ╠═f3da7627-c3db-4dd6-a650-907ad41e49a8
# ╟─b68dfdee-39fd-49cc-8285-6dcd3598c665
# ╠═fc26e8aa-1aaa-4398-bbbd-49aaf45112a2
# ╟─dbded2be-5917-4646-ac71-66cb8726a196
# ╠═d7ed25a8-5170-4b30-8927-4148a5f40563
# ╠═7915c507-408c-4854-aee3-b38ff9b48ef5
# ╠═6e3f6750-31f1-41f9-9b3e-4d045b62e61f
# ╠═65a228ad-9fc9-4417-ace2-38c9a7534e85
# ╠═4e380d8f-d337-4d4a-806e-b26a9bbd08af
# ╠═9fc0c9db-71fb-48c2-897b-386ecaa21db9
# ╠═239ec23b-7b81-4c0a-a5c4-95264514d552
# ╠═2be842b9-70c9-4310-9f98-468a23adeaa9
# ╠═54373f51-4cb7-4f07-890e-9b36cf348f96
# ╠═20320a6b-1c77-4640-ab62-c58aa7df89a2
# ╠═7e4c5eeb-b2bc-450b-a3f6-f031395083c8
# ╠═56aeab99-9c7a-4f46-b20e-635e8389c79c
# ╠═76b1f18b-0269-4ac9-b6d2-9ac2314bb31e
# ╠═0e3d76ee-c639-4b5d-8856-d116963992dd
# ╠═3d2dedeb-919b-4dba-97c6-ca24210e4f4d
# ╠═d39b06d3-5837-4fd5-90d1-5da8bc028a6c
# ╠═6e7c6fc8-c946-4bdc-aa85-b73535441ef4
# ╠═8177a2a7-a03e-4e23-af77-36ad0e73d7ba
# ╠═f23ca3f2-fbf0-4a5f-98cd-bd2f7b8ca6d1
# ╠═fe43a1c3-37da-46cd-a34f-6e395332b2d8
# ╠═b6289530-910b-4635-995a-f9253fc7b9a3
# ╠═3a52cfc6-9104-496c-b55d-27f61db86308
# ╠═08b15d6c-c1bb-4e77-bb1a-2e69928166de
# ╠═2b04d627-6170-40e6-a39a-f4c5b8aad2bc
# ╠═abf57e1b-4bf9-4afa-901c-1baa815f3053
# ╠═4ca39f31-e857-4760-948e-a4550a46110a
# ╠═c73de1e2-ce4e-4fe9-be5b-460f211535ed
# ╠═4626c7d2-e67a-48e9-b107-71e5479891f3
# ╠═fe927eee-5ae9-4429-a05a-448d0240edfb
# ╠═d46f2f0d-1c2d-4383-9ca4-68d11ca0c305
# ╠═528848af-7f75-441a-8130-a5fa6335ef80
# ╠═69f64482-05f9-43ed-980e-072dedad87b9
# ╠═a65b3ab7-4acd-46bd-b4a1-3eaae53211ae
# ╟─5f1c17cb-d7a9-413c-b41c-fee49956d945
# ╠═3fad3b11-e860-4e73-979b-3f603a5e4874
# ╠═e5b8d53d-f36f-4bd9-af04-9c8b9b7b28f0
# ╠═5b60d84a-070d-4a3f-89b0-edc48ef761b7
# ╠═27157ae0-e1d6-480d-aa6b-058e5c9a219a
# ╠═6013b000-5c56-48c4-8acc-c5308bbdb70e
# ╠═4e31235f-5aa7-4264-a417-c9fda3c60969
# ╠═6a3d6701-c780-47f4-89ca-d12e3f25f40a
# ╠═51603775-b312-40f4-8ca2-4ff3b8ce1df3
# ╠═a035dbaf-62ee-49e9-99cf-38474d2f8239
# ╠═a9d8a708-ffb2-4c3e-9796-7250ea2d570e
# ╠═1c522282-c014-4c60-94a2-cb9ccc65a2c9
# ╠═a958ee18-9741-4f50-bc5b-db661e722ef1
# ╠═e7210a3e-f4ec-4179-9adc-03e9da785250
# ╠═741621a2-0407-48b6-a269-287559884a07
# ╠═a47e0be1-d1c3-447f-a330-89459fc6eb0a
# ╠═225d1e3d-d8e7-4074-90a6-3c079a1e2cf4
# ╠═5b1f6cc3-2298-451e-aa56-9909a48be0e2
# ╠═f41ff9aa-c70b-4549-9a15-3b99d126df4d
# ╠═dee76e66-60d8-455c-8dee-66bab4bcb5ca
# ╠═40ceba2c-77ff-46f8-ac0f-312a4048a24b
# ╠═b016fd49-d835-4b2f-972b-08d0e34a51d3
# ╠═d0858655-e5b8-4f96-b64a-3020e3b1b4f2
# ╠═fa4df0a2-737c-4dd7-ae77-f1f560640eb0
# ╠═d7c1c037-5069-43fd-a7ee-c5a76b4ca08a
# ╠═907924e5-cc54-4041-a79c-3e1c683cb975
# ╠═d6ed6a4b-2b1b-4a4b-be74-73ff1f4eeb18
# ╠═6c21f5c7-3df2-4571-8639-8e63af644b1d
# ╟─892f379a-431b-4d3f-9ade-d1e483dba4df
# ╠═e95ddfe9-35c3-4fa8-ad8f-5a2ecb264d63
# ╠═7e7f06bc-0891-45df-a1f9-c2fab50a2d90
# ╠═9e0b6836-609b-4884-b6d0-b26dc10574cd
# ╠═a3131538-9c84-43dd-b6e2-1a0f172b65b1
# ╠═0dea76cf-7624-4edb-a6d1-deac05d75777
# ╠═ba74ec55-f4af-47b6-9357-76de7f3079b5
# ╠═5492f7e7-98fb-4ac0-937a-9ab8618345cf
# ╠═9e1388f4-eb05-4218-bc5d-8254f06e5f95
# ╠═09ab7f40-db5b-4358-9979-7a6e92dff622
# ╠═231e67c4-d41f-4a6d-90e7-150dc258706e
# ╠═6e85b23d-4e35-41db-92d2-4551f0332c93
# ╠═7f9321b3-84cc-43ba-a639-b4c12ee54de4
# ╠═89bc5817-10c5-43b0-8b7f-2faf27a046f9
# ╠═f63bf6dd-ff5d-4d3c-8c9b-2b79ea58d794
# ╠═c46b7178-44aa-4afa-96aa-0495660f1364
# ╠═0ab1a78c-e42d-4d08-98e0-c988ff19105b
# ╠═e13771fe-f7db-40a2-8d18-0f3f204376b2
# ╠═dd0a4123-f924-40e4-beda-43cc26a8b315
# ╠═c387345f-d0ca-4d63-895d-2618b7719efa
# ╠═91e3c6a3-35ea-4e0b-a25f-e7678a765bf5
# ╠═bc747241-5782-4015-b526-ebbdf2df1043
# ╠═2611b47d-4236-498b-91e6-8818f33f24bf
# ╠═9aec2739-be59-4b7a-8eb9-f65404bac1e8
# ╠═ec42f737-64cb-4c95-b433-ca4ceece2c76
# ╠═0dc02c5e-0373-475c-870b-10a4ac52bfb3
# ╠═be9ce077-eb3b-4cd4-b6a1-701b007cd5e1
# ╠═f7add8fa-334a-4ba9-b647-820ea2514eca
# ╠═a1102dc4-dcb7-4932-8bd0-6d10ba665e6e
# ╟─65cf2d4e-53d2-42b3-8f93-83032dfb904a
# ╠═0a99cf1e-7b66-4dbb-bfbe-bb90a5e92ea7
# ╠═a5a37d86-ce8a-4c93-b3aa-557d33174591
# ╠═b3bd5e96-fe77-4969-aca2-7a91cf466ce4
# ╠═0f5f5ea5-c674-4334-a050-5ae84d980f31
# ╠═93f8e1b6-4555-4644-a4e5-170503efae96
# ╠═9fcc1131-1339-4fb5-a30b-fc2ac4ff4c46
# ╠═af7f5c3c-6005-41a3-8e41-bec335494035
# ╠═c0c58a6b-5b0b-4171-bb96-2980e9d80946
# ╠═c466a8bb-d930-4580-a35e-e4df445da3a2
# ╠═236b6d70-f948-42ce-a7d5-52551941447e
# ╠═544a5926-94a2-4870-ae31-f624c0e0febf
# ╠═26c7809e-55c0-45b9-abfe-154fd0e3cd27
# ╠═89286624-2144-4a37-ab99-843434976356
# ╠═40866816-8b0a-4b74-b81c-bc004190a05b
# ╠═4ce0e3e7-578b-45e1-ba17-712b38ae4ea5
# ╠═5e13883f-66cd-496c-b75e-299e10ce4422
# ╠═4eabb607-6190-4441-bf07-6505cac37e3c
# ╠═866f67bb-c6fa-479d-8b7b-3baff28e4177
# ╠═7c6927fe-e574-4fdb-8960-ed92021b1423
# ╠═f1a18ca4-3142-416a-b747-8bf02f2c8c22
# ╠═d13f5fc8-ce15-4653-b666-f16a535b5f0a
# ╠═3cc85e09-5968-45d5-acb5-c4e6f7b93a8e
# ╠═ad6e2df2-1851-4954-887d-7b8ef91f4b66
# ╠═bd3e8793-fd63-4f08-802b-aa538584b5ab
# ╠═ae53a714-a365-47c9-ad98-ad1afa42a188
# ╠═6bec3770-32bb-421a-81c0-ab1377e2a016
# ╠═4c328c49-1cea-4cce-ba13-39b255d2c58b
# ╠═c0d3247a-cbc5-4b1a-906e-46e8eae3ed76
# ╠═16510ddd-8e7f-4317-a2da-266a01b54a79
# ╠═16d8d07d-db69-437e-aef7-718d101c94d4
# ╠═facdf55d-8ee1-47b1-87b7-3ff2dec1d990
# ╠═cec6b599-3a78-4924-9b0f-2fd0b68edb81
# ╠═485c39c0-3a4d-46a8-8d86-95b3ddc00948
# ╠═f0d88a8e-8587-4355-80d0-207eb10de394
# ╠═ca893747-96f1-4281-a703-f67b8058e302
# ╠═56377a6a-2937-410e-be43-88bb45e16961
# ╠═e13a30cd-2ec1-4bf8-8f5e-408780f229fc
# ╠═ad69331d-bbd9-48da-87eb-7541d4d40880
# ╠═4041f985-c779-4e45-b6e0-d68f82f0623b
# ╠═18ad27b4-9862-4771-acb0-92a3888e9781
# ╠═61ad5c87-1816-435e-ba7a-917b2626ee8c
# ╠═5bcdb98d-8cd4-48b7-aa51-4b0aa8901519
# ╠═1b690260-3121-4ea7-a3d0-db048c23fd6c
# ╠═a4e59ceb-20d2-4530-b538-20b770a96d26
# ╠═07010575-d08e-4e56-ad37-1e5250f33473
# ╠═73c5ccf0-0274-4047-964e-833cc6e7d411
# ╠═1c5e34bb-bb12-41d5-af13-e89b4ffe1dfa
# ╠═ce15fbeb-0387-45d4-bb08-1b0ed7ca6a26
# ╠═93a04579-eed5-457a-a3f9-00f76ca524c9
# ╠═eb6304ae-abed-4f6e-9ffb-06fc50d7a0b0
# ╠═ca82d77b-d0e1-4d5f-8b5c-8697e7984616
# ╠═5131a22b-5082-4e97-9a68-71aa26a1e163
# ╠═214c7095-caee-4d1a-bae5-b7e7ed56f9b6
# ╠═0c0d6d6c-252b-44be-99e2-b56741273679
# ╠═549a0ca3-1e6a-402c-b7bc-3b738fdd2139
# ╠═f8bc7a08-814e-43f2-ac40-66f1c17cea55
# ╠═0a710675-437c-40fd-8c7a-2a6488f7ef40
# ╠═c3878c17-ccec-4b9b-9b7a-aaac165b45f9
# ╠═bbd2ce4e-016d-47e1-8aa0-336a5d5d7cc3
# ╠═42efd4f6-3617-4399-acdd-2bc37ec4db2c
# ╠═a175b9d2-9462-4f27-b36c-82ed5dbefe9e
# ╠═61af12b2-0720-4ec8-b0a3-18b341d75270
# ╠═565ab859-2e87-41f4-9af2-b92ba6f9f5ef
# ╠═74e985e5-44d7-4f47-aa3a-1d445f6464e3
# ╠═60087dcd-edf5-48fa-9c00-c40f472e88b6
# ╠═2a893589-2c69-4f24-a4bb-40aa1225c038
# ╠═b12b90d1-c28b-43ea-8f04-70fd25ef5681
# ╠═0737e9d2-be09-4701-8dc3-174082bf71cc
# ╠═2ec6effc-1e3c-4a14-9e1b-6a737764c81d
# ╟─ed9a02a0-f09b-4059-b203-3eba4f6633bf
# ╠═bfcdbc9b-b629-401b-8ddd-840925bff3d8
# ╟─73b7d461-123d-4a3d-944f-bdfe78e3343e
# ╟─b4dde258-279d-4ebb-9831-db46b82be3a3
# ╠═1cd25e7a-659f-4671-a015-f25f667a1e23
# ╟─569144f5-fecd-4cf1-a427-4cf44f17e3a6
# ╠═f86dc524-e6f3-41f7-b951-e40cadac9043
# ╟─b61d8f56-28ec-4528-ba95-b116a5f67824
# ╠═18d2fdfa-4c69-4503-a08c-a8a9727d3d10
# ╟─f3a9ed0e-707f-4ae9-a8ce-81dd822a3318
# ╠═4d7c5f67-554b-49ca-9409-871c331ea515
# ╠═542f15e8-3483-4a82-bb93-dd9e5fa1691c
# ╠═45f3da3a-c1e9-44fa-a22e-3b208b44c01a
# ╟─ad7a9b4a-fa65-4b65-8b34-6d845cad4d46
# ╠═9634af66-cef4-4b92-a7d1-1bef51f8a371
# ╠═cedad643-0bee-41e3-a8f3-784f067e5775
# ╟─55460fc4-1fa7-4535-8f8f-f2fcdd235854
# ╟─32d19a8b-3686-4b3e-b1eb-6f68a1d43a5d
# ╟─95cb307e-cd53-4c13-b10d-bfbaae061d44
# ╠═b5a2bfdf-fa4b-429e-97dd-2f659d9c5f8e
# ╟─90ae52c1-d7bd-4c21-abd1-54f02cc2e519
# ╠═a7230d53-1269-4979-9bee-83bb55d5dbb9
# ╠═35a129ef-e666-4dc5-8fbc-3fac98f5ff73
# ╟─0e321be0-cd63-4181-ba1c-579b02ade9a5
# ╠═b4ff85b6-904b-4779-990b-7944e4e53820
# ╠═fb413d4f-7454-41df-9172-91e4e1e5f8fb
# ╟─05526a5d-0076-4dc1-a915-cac04ad91cb1
# ╠═e834d8ed-78bc-4ce3-9eec-18aa7b201f65
# ╠═fb117bd2-a6ee-42d9-8bc2-f1b2496570c1
# ╠═4ff49253-3730-4880-b945-b311947625fe
# ╠═43ab1a45-c52f-4987-bf8b-167b094dc76e
# ╠═fb47c667-9939-4d1e-bf23-094707276b8d
# ╟─b963a72d-482d-45cc-a59d-926c64664079
# ╠═5e931cff-8eae-4c9e-8aab-5f608ad466b5
# ╠═bbc30df1-290a-4b30-8802-25e16aa4da2c
# ╠═5f856f0d-4e84-4fad-b95c-101e84b16714
# ╠═c337e766-0970-4007-903d-927c8aec3116
# ╠═921b4df8-de25-4026-83af-cba3abf6dce3
# ╠═ce308b80-c0ad-4aa9-b0fd-f4b346371bc5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
