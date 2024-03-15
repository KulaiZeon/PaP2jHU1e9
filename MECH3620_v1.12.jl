### A Pluto.jl notebook ###
# v0.19.31

using Markdown
using InteractiveUtils

# ╔═╡ 065fbab5-6f9c-49e7-8a23-99bacd5da413
begin
	using Markdown #Type setting
	using LinearAlgebra
	using PlutoUI
	using Plots
	using AeroFuse
	using DataFrames
	using CalculusWithJulia
end


# ╔═╡ 6d8c9410-d555-11ee-31bd-a9ca7fdf7857
md"""
# MECH3620 Aircraft Design Final Project
Group 2:\
CHEUNG Yim Ho Sunny（20918447）\
NG Kow Hei Ryan(20857215)\
POON Chin Ho Jerek(20795792) \
WONG Ka Ho Samuel(20917819) \
WONG Yiu Ting Jeffery(20815554)\
"""

# ╔═╡ 848078d6-01dc-4490-ada6-80d59b09e0ed
TableOfContents(title= "Mech 3620 Group 2")

# ╔═╡ 5374c011-242b-4fa4-a023-ff96b1c05fc6
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

# ╔═╡ 439ef922-0248-401d-928d-dd2545f0b972
md"""
# Market Analysis
"""

# ╔═╡ 873c5b1c-1f29-4640-a870-7557703b759a
md"

Our team researched similar spec'd aircraft on the current market and made references to the following aircrafts:

|**Parameters**| **Aircraft 1** |**Aircraft 2** | **Aircraft 3** |
:--|----|----|----|
| Model name | $Cessna~CJ3~G2$ |$~Embraer~Phenom~300$ | $~Hawker~400~XPr~$|
| Number of Pax |$2~crews+7~passengers$|$2~crew+7~passenger$|$2~crews+9passengers$|
| Max range | $2040~nm$ | $2077~nm$| $1950~nm$|
| Payload | $968~kg~with~454kg~baggage$|$1005~kg$|$953kg$|
| Maximum Takeoff Weight(MTOW) | $6291k~g$|$8150~kg$|$7394kg$|
| Cruise Speed | $416knots$|$453knots$|$447knots$|
| Cruising Altitude($h_\text{cruise}$) | $45000~ft$|$45000~ft$|$45000~ft$
| Engine type | $Williams~FJ44-3A$|$PW535E$|$Williams~FJ44-3A$|
| Thrust of one engine| $2820~lbf$|$3360~lbf$|$3363~lbf$|


"

# ╔═╡ 69ae798d-fe27-4f30-8419-bf864258353c
md"

After analysing the performance and the specification of the existing aircraft available on the market,combining with the request from our customer, the tentative specification of our private jet(R-jet) is presented below:

| **Tentative~parameters~of~Proposed~Aircraft** | **Numbers** |
:----|----|
| Maximum Takeoff Weight(MTOW) | $6291~kg$ | 
| Capacity | $8~passenger+1~crew~or~7~passengers+2~crew$ |
| Cruise Speed | $416~kts$ |
| Cruise Altitude | $45000~ft$ |
| Maximum Payload | $968~kg~including~500kg~baggage~capacity$ | 
| Engine | $Williams~FJ44-3A$ |
| Thrust | $2820~lbf$ |
"

# ╔═╡ 7370adf7-69af-4ade-b63b-d6eff287834a
md"
# Preliminary Weight Estimation
In this part, we are using the market data to approximate the initial MOTW of R-jet\
The data and parameters of Cessna CJ3 are used for initial approximation
"

# ╔═╡ 4ae5727a-0002-4ec8-9a0b-00035b73ac7f
md"### Constants "

# ╔═╡ 4925458c-1ec5-4dbb-9ed1-321214396d8f
begin
	g = 9.81
	gamma = 1.4
	R = 273
	Wcrew = (8*100)*g #Weight(N) 8occupants configuration
	Wknown=Woccupants=Wcrew
	Wpl = 950*g #Weight(N) Around max payload from CJ3 included luagge

	SFC_cruise = 0.8/3600; 			# (1/sec) Typical value of Specific Fuel Consumption at cruise stage
	SFC_holding = 2 * SFC_cruise; 	# Loiter Pattern SFC 
	E = 2700; 					 	# (sec) Loiter time 30 minutes	

	LD_max = 11.5; 					# Lift to Drag Ratio (assume)  			
	LD_cruise = 0.866 * LD_max; 	# Cruise Lift to Drag ratio (0.866 comfirmed byTA)
	
	M = (770/3.6)/(gamma*R*216.66)^(1/2) #MAX Mach number(0.74)
	Hc = 43000*0.3048 				#Cruis Altitude(m)	
	c1 = 294.9; 					# (m/s) Speed of sound    		
	V1 = M*c1; 						# (m/s) Cruising Speed
	R1 = 2040*1852; 				# (m)   Cruising Range   
	
end;

# ╔═╡ ed43e6b5-7113-4c81-bc04-c04f5cf3ae40
md"""
### Maximum Takeoff Weight Approximation
"""

# ╔═╡ 6927ddfd-3007-4a5a-8e7a-01b21ff8180e
maximum_takeoff_weight(WPL, Wcrew, WfWTO, WeWTO) = (WPL + Wcrew)/(1 - WfWTO - WeWTO)

# ╔═╡ 1e34b422-b889-4dd6-89c6-7496fafc46fc
begin
W0i = maximum_takeoff_weight( #Weight(N) Initial MOTW
	Wpl, # Payload weight, N
	Wcrew, # Crew weight, N
	0.1, # Fuel-weight fraction referencing from tutorial
	3900/6300 # Empty-weight fraction referencing from CJ3
)
end

# ╔═╡ cf5c0521-cf43-42ab-8ac2-728559216e7b
md" ### Segment Fuel Fraction


"

# ╔═╡ 16dd553a-3e71-41df-b5e8-c6cab9a63f17
html"""
<p>Fuel fraction by class</p>

<img src="https://photos.fife.usercontent.google.com/pw/AP1GczPl6Rnstt4rWCSNul80NF7GmLfeTCT-ypr0UO4QgUSRk5kqgOaLWV5J=w598-h272-s-no-gm?authuser=1"

>
"""

# ╔═╡ 8ffec899-a8f5-4255-901e-ae60bf52ab25
html"""
<p>Flight path</p>

<img src="https://s2.ezgif.com/tmp/ezgif-2-bebbe4e85c.jpg"

>
"""

# ╔═╡ e88b5067-b4e1-4dea-9c70-7e2d5f8f05e8
md"""
We consider a mission consisting of 12 segments in the following order:

1. Warmup
2. Taxing
3. Takeoff 
4. Climb
5. Cruise: $476$ nautical miles (nmi) [TOC to VEPAM]
6. Climb [VEPAM to KARAN]
7. Cruise: $544$ nautical miles (nmi) [KARAN to ESBUM]
8. Loiter: $5$ mins [ESBUM to ELALO]
9. Cruise: $77$ nmi [ELALO to TOD]
10. Loiter: $30$ mins "By the tutorial time"
11. Descent
12. Landing
"""

# ╔═╡ a92053bd-3057-4eac-9913-b053e35e1f18
md"
### Cruise Weight Fraction
$$WF_{\mathrm{cruise}} = \exp\left(-\frac{R \times SFC}{V \times (L/D)_\text{cruise}}\right)$$
The cruise lift-to-drag ratio can be approximated as $(L/D)_\text{cruise} = 0.866(L/D)_\max$.
"

# ╔═╡ 836289a7-a6ae-48e9-90b2-eb30c3d865f0
md"
### Loiter Weight Fraction

$$WF_\text{Loiter} = \exp\left(-\frac{E \times SFC}{(L/D)_\max}\right)$$
The SFC in this segment can be approximated as: $SFC_\text{Loiter} \approx 2 \times SFC$
"

# ╔═╡ eec3569b-d858-4549-a4a9-9176e8a62989
begin
	cruise_weight_fraction(R, SFC, V, L_D) = exp(-R * SFC / (V * L_D))
    loiter_weight_fraction(E, SFC, L_D) = exp(-E * SFC / L_D)
end;

# ╔═╡ 8672a6f2-415c-4605-b7c5-7420c47da4a5
begin
	#This will assume that LD and SFC would change in different altitude
	crusieLD = 10 #(dimensionless)  By Roskam 10-12
	crusieSFC = 0.5/3600 #(sec-1)  By Roskam 0.5-0.9
	loiterLD = 12 #(dimensionless)  By Roskam 12-14
	loiterSFC = 0.4/3600 #(sec-1)  By Roskam 0.4-0.6

	crusieR1 = (578-102)*1852 #(m) TOC to VEPAM
	crusieR2 = (1215-671)*1852 #(m) KARAN to ESBUM
	crusieR3 = (1332-1255)*1852 #(m) ELALO to TOD

	loiterE1 = 5*60 #(s) ESBUM to ELALO
	loiterE2 = 30*60 #(s) "By the tutorial time"
	
end;

# ╔═╡ a26c2944-b6f0-41b2-8375-c9df91370234
begin
	crusieFF1 = cruise_weight_fraction(crusieR1, crusieSFC, V1, crusieLD)
	crusieFF2 = cruise_weight_fraction(crusieR2, crusieSFC, V1, crusieLD)
	crusieFF3 = cruise_weight_fraction(crusieR3, crusieSFC, V1, crusieLD)

	loiterFF1 = loiter_weight_fraction(loiterE1, loiterSFC, loiterLD)
	loiterFF2 = loiter_weight_fraction(loiterE2, loiterSFC, loiterLD)
end

# ╔═╡ 11631c94-6c25-435f-a640-365218cc7abc
begin
	WarmupFF = 0.99
	TaxiFF = 0.995
	TakeoffFF = 0.995 
	ClimbFF = 0.98 
	DescentFF = 0.99 
	LandingFF = 0.992 
end;

# ╔═╡ 1696eb91-1317-49d2-8762-22092bb3f429
md"""## Fuel Weight Fractions
The fuel weight fraction is given by:
```math
\frac{W_f}{W_0} = a\left(1 - \prod_{i = 1}^{N}\frac{W_{f_i}}{W_{f_{i-1}}}\right)
```
where the input $a$ is the additional fuel reserve (usually as a percentage of the total).
"""

# ╔═╡ 523094f1-8534-4e7a-8f65-034291332647
fuel_weight_fraction(fuel_fracs, a) = a * (1 - prod(fuel_fracs));

# ╔═╡ b00fb477-0a26-44ed-a8f9-c8504a454845
FFs = [WarmupFF,TaxiFF,TakeoffFF,ClimbFF,crusieFF1,ClimbFF,crusieFF2,loiterFF1,crusieFF3,loiterFF2,DescentFF,LandingFF];

# ╔═╡ 030faac0-b5af-424a-b422-fdf7e3fa9567
WfWTO = fuel_weight_fraction(FFs, 1.06)

# ╔═╡ b979ddb9-ca6b-4ee2-942c-661eec458189
md"### Plot-Fuel Fraction vs Mission Segment Number"

# ╔═╡ 63aa90d8-ef35-41b5-9f39-1fdfe5d8eb9a
plot( # You can ignore this for now. Alternatively, use Live Docs to understand the functions used.
	eachindex(FFs), # Mission segment numbers
	cumprod(FFs), # Cumulative fuel fractions
	xlabel = "Mission Segment Number", 
	ylabel = "Fuel Fraction", 
	label = "Fuel fraction by segment"
)

# ╔═╡ 4b4d0281-5ef2-46c0-b711-fdab27e95375
md"""## Empty Weight Fraction
"""

# ╔═╡ 26f8c221-f9be-4a80-895c-2c04fe74e12b
html"""
<h5>Roskam's regrssion coefficient</h5>

<img src="https://s4.ezgif.com/tmp/ezgif-4-32ae401755.jpg"

>
"""

# ╔═╡ 3bb0b409-9b52-4f30-9217-734e54989e8d
begin
	We_array=[3874, 5316.1, 4885.6, 5831.8, 11793/2.205, 23349/2.205, 15100/2.205,25360/2.205, 1610, 7203/2.205]*g #10*1 matrix (N)
	W0_array=[6291,10433,7303,9525,8150,38850/2.205,26100/2.205,19440,2727,4519]*g #10*1 matrix (N)
end;

# ╔═╡ b6c97d72-9bc5-4065-8233-9efa6ac8d5ce
begin
	X = [ones(size(We_array)) log10.(We_array)]
	y = log10.(W0_array)

	(O,P) = inv(X'*X)*X'*y
	pltx = 4:0.1:5
	plty = O*ones(size(pltx))+P*pltx
end;

# ╔═╡ f8656f65-afc2-4700-9976-188213d1428b
md"### Plot of Maximum Takeoff Weight vs Empty Weight"

# ╔═╡ cee7c39f-3c6d-467d-839e-0379b64251d5
begin
	scatter(log10.(We_array), log10.(W0_array), legend=false, xlabel="Empty Weight(log10)", ylabel="MOTW(log10)")
	plot!(pltx, plty)
end

# ╔═╡ 06a3b160-88ff-4e6e-a633-36f7bae15a72
empty_weight_raymer(WTO, A, B) = A * WTO^B

# ╔═╡ 960c6d25-0a82-4368-9d34-54cb8624c6d0
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
end;

# ╔═╡ 17e18aa0-29fe-46e9-9a6f-85188a818695
WTOs, errors = compute_maximum_takeoff_weight(
					W0i, Wpl, Wcrew, WfWTO, 10^(-O/P), (1-P)/P;
					num_iters = 20, 
					tol = 1e-12
				   )

# ╔═╡ 6e2b5ba0-e4e6-4af2-ae96-48f2f86e6f6b
md" ### Maximum takeoff weight"

# ╔═╡ 29c77775-f591-4cbc-8373-7eb08976168a
MTOW_kg = WTOs[end] / g ### The WfWTO might need to lower

# ╔═╡ 49ebf579-ff75-4b83-86f1-aa46ce738597
md"""
# Preliminary Sizing
"""

# ╔═╡ 2addc67b-df44-4f9c-a02b-ab48444db914
md"""
We calculate the specification of our aircraft to be as follows:
"""

# ╔═╡ ab5bd95d-b853-4f8b-a4ed-9529cf461761
md"""
	1. Aspect Ratio (We make reference to the CJ3 G2 aircraft):

```math
Aspect ~ Ratio ~ (AR) = \frac{b^2}{s}
```
	"""

# ╔═╡ 916578b7-844a-48ea-919f-5ac1063bfaf7
md"""
	Substituting the specification of CJ3 G2 into the equation:

```math
AR_(CJ3) = \frac{16.26^2}{27.32}
```
	"""

# ╔═╡ 000dd8c3-af7f-4a02-b378-2dd1c32deadc
begin
	CJ3_WingSpan = 16.26 #In meters
	CJ3_WingArea = 27.32 #In meters-squared
	CJ3_AR = CJ3_WingSpan^2 / CJ3_WingArea 
	println("The target aspect ratio is: ",CJ3_AR)
end

# ╔═╡ f07aba16-01db-4d2d-81a6-0ce39e6bc598
md"""
	2. Wing Area (From AR to Wing Area):

```math
Wing~Area~(RJet) = \frac{b^2}{AR}
```
	"""

# ╔═╡ 10de6318-abec-49cf-a57a-2fc016ce7829
md"""
	Substituting the specification of RJet into the equation:

```math
AR_(RJet) = \frac{15.5^2}{9.68}
```
	"""

# ╔═╡ e2fe770b-e4a2-42ef-bc45-24f4d48b6332
begin
	Rjet_AR = 9.68 
	Rjet_WingSpan = 15.5 #In meters
	Rjet_WingArea = Rjet_WingSpan^2 / Rjet_AR 
	println("The target wing area is: ",Rjet_WingArea)
end

# ╔═╡ 6ffb8005-55f0-4378-90aa-08fd63c94ef4
md"""
	3. Wing Loading:

```math
Wing~Loading~(RJet) = \frac{MTOW}{Wing~Area}
```
	"""

# ╔═╡ 43fbfc6a-ecaa-4361-b014-cadeab4bc5da
md"""
	Substituting the specification of RJet into the equation:

```math
Wing~Loading~(RJet) = \frac{8,000}{24.82}
```
	"""

# ╔═╡ 0c05bd61-968b-4dc6-86ce-9688b5b30cef
begin
	Rjet_MTOW = 8000 
	Rjet_WingLoading = Rjet_MTOW / Rjet_WingArea 
	println("The target wing loading is: ",Rjet_WingLoading)
end

# ╔═╡ 01f5a68d-81af-49c5-8528-080ad028abe9
md"""


Based on our mission requirement, and making reference to the reference aircraft of Cessna CJ3 Gen 2, we deduce the appropriate specification of our aircraft to be as follows:

| **Parameter** | **Value (Metric)** | **Value (Imperial)** |
:-------------|-----------------------|-----------------------
| Aspect Ratio ($AR$) | $9.68$ | $9.68$ |
| Span ($b$) | $15.5~m$ | $50.82~ft$ |
| Wing Area ($S$) | $24.82~m^2$ | $267.1~ft^2$ |
| MTOW ($W_0$) | $8,000~kg$ | $17,637~lbs$ |
| Takeoff Wing Loading $(W/S)_\text{takeoff}$ | $322.33~kg/m^2$ | $66.01~lbs/ft^2$ |
| Cruise Mach Number $(M_\text{cruise})$ | $0.85$ | $0.85$ |
| Cruise Altitude ($h_\text{cruise}$) | $13106~m$ | $43,000~ft$ |
| Ceiling Altitude ($h_\text{ceiling}$) | $13716~m$ | $45,000~ft$ | 
---

"""

# ╔═╡ 673b3a13-557d-4291-a106-50dd19596999
# ╠═╡ disabled = true
#=╠═╡
begin 
	using Plots
	# import PlotlyJS     # For enabling interactivity with the plots
end
  ╠═╡ =#

# ╔═╡ e001fec6-265f-4f5d-ad14-7a69b5fd26c8
gr( # Change to plotlyjs() for interactivity
	grid = true, 	   # Disable the grid for a e s t h e t i c
	size = (800, 520), # Adjust the dimensions to suit your monitor
	dpi = 300     	   # Higher DPI = higher density
)

# ╔═╡ f9312cdd-cdb3-4e2a-b876-95734727a16c
md"## Drag Polar"

# ╔═╡ a350ce72-94c2-4bc8-8383-cad4de6c3b74
md"""
### Induced Drag Coefficient

```math
k = \frac{1}{\pi e AR}
```
"""

# ╔═╡ 5628e1d5-4c0f-4252-93cd-a33210b1977c
induced_drag_coefficient(e, AR) = 1 / (pi * e * AR)

# ╔═╡ d180eebc-ad70-47f7-b2a6-8dce912c63c0
begin
	begin 
		e_1  = 0.75
		AR_1 = 9.8
		k = induced_drag_coefficient(e_1, AR_1)
	end
	
	println("The induced drag coefficient (k) is: ",k)
end

# ╔═╡ 0d4758d7-6b80-4da9-bfbf-869e2e695a69
md"""
### Plot size and colour change """

# ╔═╡ e29eede5-d573-4a17-b77e-1ebdc1a0f43b
gr(
	size = (900, 700),  # INCREASE THE SIZE FOR THE PLOTS HERE.
	palette = :tab20    # Color scheme for the lines and markers in plots
)

# ╔═╡ a717ac86-85b0-46b4-87d1-8cc46df43858
md"""
### Fuselage Design
"""

# ╔═╡ 37ce28ef-f628-4a97-a81b-4834a8e18884
# Fuselage definition
fuse = HyperEllipseFuselage(
    radius = 3.04,          # Radius, m
    length = 63.5,          # Length, m
    x_a    = 0.15,          # Start of cabin, ratio of length
    x_b    = 0.7,           # End of cabin, ratio of length
    c_nose = 1.6,            # Curvature of nose
    c_rear = 1.3,           # Curvature of rear
    d_nose = -0.5,          # "Droop" or "rise" of nose, m
    d_rear = 1.0,           # "Droop" or "rise" of rear, m
    position = [0.,0.,0.]   # Set nose at origin, m
)

# ╔═╡ 991c242b-5668-4071-bdb2-0469c81cbe0b
toggles

# ╔═╡ 24032cff-7150-43f4-80d5-6f534cc8d461
plt_vlm

# ╔═╡ e1f6717b-5006-4539-9935-dca8358c03a1
md"""
### Wing Design (NACA4412 wing) (NACA0012 stablizer)
"""

# ╔═╡ c09c587f-aba5-472e-a476-33e16ed94c9c
begin
	# AIRFOIL PROFILES
	foil_w_r = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=b737a-il")) # Root
	foil_w_m = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=b737b-il")) # Midspan
	foil_w_t = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=b737c-il")) # Tip
end

# ╔═╡ 5b685898-dbba-439a-b07f-f703491ad986
# Wing
wing = Wing(
    foils       = [foil_w_r, foil_w_m, foil_w_t], # Airfoils (root to tip)
    chords      = [14.0, 9.73, 1.43561],        # Chord lengths
    spans       = [14.0, 46.9] / 2,             # Span lengths
    dihedrals   = fill(6, 2),                   # Dihedral angles (deg)
    sweeps      = fill(35.6, 2),                # Sweep angles (deg)
    w_sweep     = 0.,                           # Leading-edge sweep
    symmetry    = true,                         # Symmetry

	# Orientation
    angle       = 3,       # Incidence angle (deg)
    axis        = [0, 1, 0], # Axis of rotation, x-axis
    position    = [0.35fuse.length, 0., -2.5]
)

# ╔═╡ fab99f96-2d8c-465d-90c2-f2f9773920cd
md"
### Wing Geometric Information
"

# ╔═╡ 4e73edc6-ac5f-43cc-a094-f35925ed64d2
foils(wing)

# ╔═╡ 33a11564-5b1b-4376-ad64-7cc0ab2deb50
chords(wing)

# ╔═╡ 2a20fc7a-95c0-478b-bc16-57221f68872e
spans(wing)

# ╔═╡ c54839c8-963d-45b1-a188-aaedb77fdab1
dihedrals(wing)

# ╔═╡ 83fe2f1c-2071-4890-9646-3140c6a95ec0
sweeps(wing)

# ╔═╡ 2eff6e0d-c8a8-4bb8-9fd5-0072e211068f
begin
	wingAR = aspect_ratio(wing) # Aspect ratio
	wingspan = spans(wing) # Span length (m)
	wingarea = projected_area(wing) # Projected area (m²)
	wingchord = mean_aerodynamic_chord(wing) # Mean aerodynamic chord (m)
	x_w, y_w, z_w = wing_mac = mean_aerodynamic_center(wing) # Mean aerodynamic center (m)
	
end

# ╔═╡ b572d05c-98b2-4653-a012-60310d3700c3
md"""
# CODES IN THIS SECTION ARE NOT CHANGED, reasoning: Airfoil not yet selected.
"""

# ╔═╡ 87c771d5-fde7-4863-a43d-a33fb5a05d2f
md"""
### Parabolic Drag Polar

```math
C_D = C_{D_\min} + k\left(C_L - C_{L_{\text{min drag}}}\right)^2, \quad k = \frac{1}{\pi e AR}
```
"""

# ╔═╡ 63dcc3ab-2fe8-4de7-98bd-bcf9f15a71bb
drag_polar(CD0, k, CL, CL0 = 0.) = CD0 + k * (CL - CL0)^2

# ╔═╡ 3f15b08b-964e-48ce-ba8e-62315801405b
md"Let's define a range of lift coefficients over which we would like to see the variation of the drag polar."

# ╔═╡ 8a008a5d-2463-4c19-8c1f-0955cb204b7b
cls = -1.5:0.05:1.5

# ╔═╡ 11ede02c-9da3-4728-9457-db2c2126f850
md"Here we consider an uncambered airfoil, hence $C_{L_\text{min drag}} = C_{L_{\alpha = 0}} = 0$ and $C_{D_\min} = C_{D_0}$"

# ╔═╡ 0b7fc8d2-3939-4d20-8ce1-542a2fc3bc02
begin
	CD_min = 0.01612
	CL_min_drag = 0.0
	cds = drag_polar.(CD_min, k, cls, CL_min_drag)
end

# ╔═╡ 130fff97-61e9-4192-9fc7-011cdc9d4c73
begin 
	CD0 = CD_min
	CL0 = CL_min_drag
end

# ╔═╡ 053e352f-5eaf-42d2-b9cb-f6749e36ce8f
begin
	CD_min_2 = 0.01
	CL_min_drag_2 = 0.2
	cds_2 = drag_polar.(CD_min_2, k, cls, CL_min_drag_2)
end;

# ╔═╡ 5c7ea184-20cf-419f-93f8-6250d9a419e5
begin
	plot(cds, cls, 
		 label = "CDₘᵢₙ = $CD_min, CL (min drag) = $CL_min_drag",
		 xlabel = "CD", ylabel = "CL", title = "Drag Polar")
	plot!(cds_2, cls, 
		  label = "CDₘᵢₙ = $CD_min_2, CL (min drag) = $CL_min_drag_2")
end

# ╔═╡ 9e7308b3-7d80-4189-a21a-0667f7b828e5
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

# ╔═╡ d82744d2-1481-4ffa-8417-44ad6eb6be64
dynamic_pressure(rho, V) = 1/2 * rho * V^2

# ╔═╡ bb4a10bc-40c2-4efd-904e-72ff4749ddab
wing_loading_stall_speed(V_stall, CL_max, ρ = 1.225) = dynamic_pressure(ρ, V_stall) * CL_max

# ╔═╡ f1c3d892-7ee5-466b-972c-9acb7da9e531
begin
	V_stall = 0.514 * 150 # 150 knots to m/s
	CL_max = 2.0 		  # Maximum lift coefficient with no flaps
end;

# ╔═╡ feb7f610-5135-447f-bc37-f83e7e8a73e6
md"Density ratio to sea level: $\sigma = \rho/\rho_{SL}$"

# ╔═╡ b3019f35-0140-4338-8567-94713b3d3bca
σ = 0.95

# ╔═╡ f7b55236-22df-497e-9e91-f0fdd0297233
WbS_stall = wing_loading_stall_speed(V_stall, CL_max, σ * 1.225)

# ╔═╡ 43e5a697-e91b-4b30-8f95-9aa9dfcbeda1
md"We need to plot a vertical line, so we define an array with the same elements repeated using the `fill()` function."

# ╔═╡ d2ed7ae7-2831-450e-8796-11bc8979c7a0
n = 15

# ╔═╡ 6d8672b3-52c9-4861-a750-9e9d80646116
stalls = fill(WbS_stall, n);

# ╔═╡ c8ff8fe0-2124-483e-b689-446bedd2afbf
TbWs = range(0, 0.5, length = n);

# ╔═╡ 4f86c8b6-9fcf-42e9-9232-36eca90b6489
begin 
	plot(xlabel = "W/S, N/m²", ylabel = "T/W", title = "Matching Chart", xlim = (6600, 7200))
	plot!(stalls, TbWs, label = "Stall")
	annotate!(6800, 0.2, "Feasible")
	annotate!(7050, 0.2, "Infeasible")
end

# ╔═╡ 06398c2e-f193-4257-ad3f-d7f51c9c350b
md"""### Takeoff
Using Raymer's chart for the takeoff condition:

```math
\frac{(W_0/S)}{\sigma C_{L_{TO}}(T_0/W_0)} \leq TOP = 280
```

"""

# ╔═╡ ae92fd2f-cf70-477f-9da9-861ae7ef6bad
takeoff_condition(WbS, σ, CL_takeoff, TOP) = (0.0929/4.448) * WbS / (TOP * σ * CL_takeoff)

# ╔═╡ f249f1a0-f11c-446b-b91e-a63a55df45ef
begin
	CL_takeoff = 2.0
	TOP = 280
end

# ╔═╡ 4bb61ea6-1b71-4d94-bdd2-58b8c016f171
wing_loadings = 1000:10000;

# ╔═╡ d415634d-1ea9-435a-8de5-4b7a2350cd17
TbW_takeoff = takeoff_condition.(wing_loadings, σ, CL_takeoff, TOP)

# ╔═╡ d6f94de5-1457-426f-875a-35f8031bfafc
begin
	plot(ylabel = "(T/W)", xlabel = "(W/S), N/m²", title = "Matching Chart")
	plot!(stalls, TbWs, label = "Stall")
	plot!(wing_loadings, TbW_takeoff, label = "Takeoff")
	annotate!(4000, 0.3, "Feasible")
	annotate!(5000, 0.05, "Infeasible")
	annotate!(9000, 0.2, "Infeasible")
end

# ╔═╡ 8c14d493-f5ef-4f82-9970-8369acf181a7
md"""### Landing

```math
\frac{W_0}{S} \leq \sigma \left(\frac{W_0}{W_L}\right)\left[\frac{{\color{orange} g} C_{L_\max, L}}{5}\left(s_L - s_a\right)\right]
```

The $\color{orange} g$ is included to convert the weight's units into Newtons.
"""

# ╔═╡ 4ad77bb4-ea2c-4f2d-86a7-badb5b9fac9c
landing_condition(σ, CL_max, s_FL, s_a, r = 0.6, g = 9.81) = σ * g * CL_max / 5 * (r * s_FL - s_a)

# ╔═╡ a8b1c93c-30f6-4587-a5e3-6a5d73aee85d
begin
	CL_landing = 2.2 # Maximum lift coefficient at landing
	s_L = 2800 		 # Runway length
	s_a = 305 		 # Approach distance
	r = 0.6 		 # FAR-25 condition
end

# ╔═╡ bee5fe62-691b-4a84-9aae-a4c90260af96
landing_sls = 1/WF_landing * landing_condition(σ, CL_landing, s_L, s_a, r)

# ╔═╡ 21cf6e63-16e7-4d8c-8f0f-6db068b600ed
wbs_landing = fill(landing_sls, n);

# ╔═╡ ef4c561e-89c4-42e2-a169-f30a5bbe0871
begin
	plot(ylabel = "(T/W)", xlabel = "(W/S), N/m²", title = "Matching Chart")
	plot!(stalls, TbWs, label = "Stall")
	plot!(wing_loadings, TbW_takeoff, label = "Takeoff")
	plot!(wbs_landing, TbWs, label = "Landing")
	annotate!(4000, 0.3, "Feasible")
end

# ╔═╡ b4323785-5a16-41ed-954b-effbec5002b9


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
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "bc90aea6404ad45f343e688683a422edefefecf5"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "793501dcd3fa7ce8d375a2c878dca2296232686e"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.2"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "MacroTools", "Test"]
git-tree-sha1 = "a7055b939deae2455aa8a67491e034f735dd08d3"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.33"

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
git-tree-sha1 = "247efbccf92448be332d154d6ca56b9fcdd93c31"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.6.1"

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
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.CalculusWithJulia]]
deps = ["Base64", "Contour", "ForwardDiff", "HCubature", "IntervalSets", "JSON", "LinearAlgebra", "PlotUtils", "Random", "RecipesBase", "Reexport", "Requires", "Roots", "SpecialFunctions", "SplitApplyCombine", "Test"]
git-tree-sha1 = "f8f38600024939e5921800fd250cc3cdb93bec09"
uuid = "a2e0e22d-7d4c-5312-9169-8b992201a882"
version = "0.1.3"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "e0af648f0692ec1691b5d094b8724ba1346281cf"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.18.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "cd67fc487743b2f0fd4380d4cbd3a24660d0eec8"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.3"

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
deps = ["UUIDs"]
git-tree-sha1 = "886826d76ea9e72b35fcd000e535588f7b60f21d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

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
git-tree-sha1 = "8cfa272e8bdedfa88b6aefbbca7c19f1befac519"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.3.0"

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
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

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
git-tree-sha1 = "e82c3c97b5b4ec111f3c1b55228cebc7510525a2"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.25"

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
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

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
git-tree-sha1 = "9a68d75d466ccc1218d0552a8e1631151c569545"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.4.5"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

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
git-tree-sha1 = "e95b36755023def6ebc3d269e6483efa8b2f7f65"
uuid = "19dc6840-f33b-545b-b366-655c7e3ffd49"
version = "1.5.1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "abbbb9ec3afd783a7cbd82ef01dcd088ea051398"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.1"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

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
deps = ["Dates", "Random"]
git-tree-sha1 = "3d8866c029dd6b16e69e0d4a939c4dfcb98fac47"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.8"
weakdeps = ["Statistics"]

    [deps.IntervalSets.extensions]
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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f689897ccbe049adb19a065c495e75f372ecd42b"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.4+0"

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
git-tree-sha1 = "f12f2225c999886b69273f84713d1b9cb66faace"
uuid = "2ee39098-c373-598a-b85f-a56591580800"
version = "1.15.0"

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
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

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
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

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
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

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
version = "2.28.2+0"

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
version = "2022.10.11"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "2ac17d29c523ce1cd38e27785a7d23024853a4bb"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.10"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc6e1927ac521b659af340e0ca45828a3ffc748f"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.12+0"

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
version = "10.42.0+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "a935806434c9d4c506ba941871b327b96d41f2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.0"

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
version = "1.9.2"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "f92e1315dadf8c46561fb9396e525f7200cdc227"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.5"

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
git-tree-sha1 = "bd7c69c7f7173097e7b5e1be07cee2b8b7447f51"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.54"

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
git-tree-sha1 = "9ebcd48c498668c7fa0e97a9cae873fbee7bfee1"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.9.1"

[[deps.Quaternions]]
deps = ["LinearAlgebra", "Random", "RealDot"]
git-tree-sha1 = "9a46862d248ea548e340e30e2894118749dc7f51"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.7.5"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
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
deps = ["ChainRulesCore", "CommonSolve", "Printf", "Setfield"]
git-tree-sha1 = "0f1d92463a020321983d04c110f476c274bafe2e"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.0.22"

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
git-tree-sha1 = "792d8fd4ad770b6d517a13ebb8dadfcac79405b8"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.6.1"

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
git-tree-sha1 = "5165dfb9fd131cf0c6957a3a7605dede376e7b63"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

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
git-tree-sha1 = "48f393b0231516850e39f6c756970e7ca8b77045"
uuid = "03a91e81-4c3e-53e1-a0a4-9c0c8f19dd66"
version = "1.2.2"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "f295e0a1da4ca425659c57441bcb59abb035a4bc"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.8.8"

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
git-tree-sha1 = "2aded4182a14b19e9b62b063c0ab561809b5af2c"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.8.0"
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
version = "1.9.0"

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
git-tree-sha1 = "0a3db38e4cce3c54fe7a71f831cd7b6194a54213"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.16"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

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
git-tree-sha1 = "1fbeaaca45801b4ba17c251dd8603ef24801dd84"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.2"
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
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

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
git-tree-sha1 = "522b8414d40c4cbbab8dee346ac3a09f9768f25d"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.4.5+0"

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
version = "1.2.13+0"

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
version = "5.8.0+0"

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
git-tree-sha1 = "93284c28274d9e75218a416c65ec49d0e0fcdf3d"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.40+0"

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
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

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

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╠═6d8c9410-d555-11ee-31bd-a9ca7fdf7857
# ╠═065fbab5-6f9c-49e7-8a23-99bacd5da413
# ╠═848078d6-01dc-4490-ada6-80d59b09e0ed
# ╠═5374c011-242b-4fa4-a023-ff96b1c05fc6
# ╠═439ef922-0248-401d-928d-dd2545f0b972
# ╠═873c5b1c-1f29-4640-a870-7557703b759a
# ╠═69ae798d-fe27-4f30-8419-bf864258353c
# ╠═7370adf7-69af-4ade-b63b-d6eff287834a
# ╠═4ae5727a-0002-4ec8-9a0b-00035b73ac7f
# ╠═4925458c-1ec5-4dbb-9ed1-321214396d8f
# ╟─ed43e6b5-7113-4c81-bc04-c04f5cf3ae40
# ╟─6927ddfd-3007-4a5a-8e7a-01b21ff8180e
# ╟─1e34b422-b889-4dd6-89c6-7496fafc46fc
# ╟─cf5c0521-cf43-42ab-8ac2-728559216e7b
# ╠═16dd553a-3e71-41df-b5e8-c6cab9a63f17
# ╠═8ffec899-a8f5-4255-901e-ae60bf52ab25
# ╠═e88b5067-b4e1-4dea-9c70-7e2d5f8f05e8
# ╠═a92053bd-3057-4eac-9913-b053e35e1f18
# ╟─836289a7-a6ae-48e9-90b2-eb30c3d865f0
# ╠═eec3569b-d858-4549-a4a9-9176e8a62989
# ╠═8672a6f2-415c-4605-b7c5-7420c47da4a5
# ╠═a26c2944-b6f0-41b2-8375-c9df91370234
# ╠═11631c94-6c25-435f-a640-365218cc7abc
# ╟─1696eb91-1317-49d2-8762-22092bb3f429
# ╠═523094f1-8534-4e7a-8f65-034291332647
# ╠═b00fb477-0a26-44ed-a8f9-c8504a454845
# ╠═030faac0-b5af-424a-b422-fdf7e3fa9567
# ╟─b979ddb9-ca6b-4ee2-942c-661eec458189
# ╠═63aa90d8-ef35-41b5-9f39-1fdfe5d8eb9a
# ╟─4b4d0281-5ef2-46c0-b711-fdab27e95375
# ╠═26f8c221-f9be-4a80-895c-2c04fe74e12b
# ╠═3bb0b409-9b52-4f30-9217-734e54989e8d
# ╠═b6c97d72-9bc5-4065-8233-9efa6ac8d5ce
# ╠═f8656f65-afc2-4700-9976-188213d1428b
# ╠═cee7c39f-3c6d-467d-839e-0379b64251d5
# ╠═06a3b160-88ff-4e6e-a633-36f7bae15a72
# ╠═960c6d25-0a82-4368-9d34-54cb8624c6d0
# ╠═17e18aa0-29fe-46e9-9a6f-85188a818695
# ╟─6e2b5ba0-e4e6-4af2-ae96-48f2f86e6f6b
# ╟─29c77775-f591-4cbc-8373-7eb08976168a
# ╟─49ebf579-ff75-4b83-86f1-aa46ce738597
# ╟─2addc67b-df44-4f9c-a02b-ab48444db914
# ╟─ab5bd95d-b853-4f8b-a4ed-9529cf461761
# ╟─916578b7-844a-48ea-919f-5ac1063bfaf7
# ╟─000dd8c3-af7f-4a02-b378-2dd1c32deadc
# ╟─f07aba16-01db-4d2d-81a6-0ce39e6bc598
# ╟─10de6318-abec-49cf-a57a-2fc016ce7829
# ╟─e2fe770b-e4a2-42ef-bc45-24f4d48b6332
# ╟─6ffb8005-55f0-4378-90aa-08fd63c94ef4
# ╟─43fbfc6a-ecaa-4361-b014-cadeab4bc5da
# ╟─0c05bd61-968b-4dc6-86ce-9688b5b30cef
# ╠═01f5a68d-81af-49c5-8528-080ad028abe9
# ╠═673b3a13-557d-4291-a106-50dd19596999
# ╠═e001fec6-265f-4f5d-ad14-7a69b5fd26c8
# ╠═f9312cdd-cdb3-4e2a-b876-95734727a16c
# ╠═a350ce72-94c2-4bc8-8383-cad4de6c3b74
# ╠═5628e1d5-4c0f-4252-93cd-a33210b1977c
# ╟─d180eebc-ad70-47f7-b2a6-8dce912c63c0
# ╠═0d4758d7-6b80-4da9-bfbf-869e2e695a69
# ╠═e29eede5-d573-4a17-b77e-1ebdc1a0f43b
# ╠═a717ac86-85b0-46b4-87d1-8cc46df43858
# ╠═37ce28ef-f628-4a97-a81b-4834a8e18884
# ╠═991c242b-5668-4071-bdb2-0469c81cbe0b
# ╠═24032cff-7150-43f4-80d5-6f534cc8d461
# ╠═e1f6717b-5006-4539-9935-dca8358c03a1
# ╠═c09c587f-aba5-472e-a476-33e16ed94c9c
# ╠═5b685898-dbba-439a-b07f-f703491ad986
# ╠═fab99f96-2d8c-465d-90c2-f2f9773920cd
# ╠═4e73edc6-ac5f-43cc-a094-f35925ed64d2
# ╠═33a11564-5b1b-4376-ad64-7cc0ab2deb50
# ╠═2a20fc7a-95c0-478b-bc16-57221f68872e
# ╠═c54839c8-963d-45b1-a188-aaedb77fdab1
# ╠═83fe2f1c-2071-4890-9646-3140c6a95ec0
# ╠═2eff6e0d-c8a8-4bb8-9fd5-0072e211068f
# ╠═b572d05c-98b2-4653-a012-60310d3700c3
# ╠═87c771d5-fde7-4863-a43d-a33fb5a05d2f
# ╠═63dcc3ab-2fe8-4de7-98bd-bcf9f15a71bb
# ╟─3f15b08b-964e-48ce-ba8e-62315801405b
# ╟─8a008a5d-2463-4c19-8c1f-0955cb204b7b
# ╟─11ede02c-9da3-4728-9457-db2c2126f850
# ╠═0b7fc8d2-3939-4d20-8ce1-542a2fc3bc02
# ╠═130fff97-61e9-4192-9fc7-011cdc9d4c73
# ╠═053e352f-5eaf-42d2-b9cb-f6749e36ce8f
# ╠═5c7ea184-20cf-419f-93f8-6250d9a419e5
# ╠═9e7308b3-7d80-4189-a21a-0667f7b828e5
# ╠═d82744d2-1481-4ffa-8417-44ad6eb6be64
# ╠═bb4a10bc-40c2-4efd-904e-72ff4749ddab
# ╠═f1c3d892-7ee5-466b-972c-9acb7da9e531
# ╠═feb7f610-5135-447f-bc37-f83e7e8a73e6
# ╠═b3019f35-0140-4338-8567-94713b3d3bca
# ╠═f7b55236-22df-497e-9e91-f0fdd0297233
# ╠═43e5a697-e91b-4b30-8f95-9aa9dfcbeda1
# ╠═d2ed7ae7-2831-450e-8796-11bc8979c7a0
# ╠═6d8672b3-52c9-4861-a750-9e9d80646116
# ╠═c8ff8fe0-2124-483e-b689-446bedd2afbf
# ╠═4f86c8b6-9fcf-42e9-9232-36eca90b6489
# ╠═06398c2e-f193-4257-ad3f-d7f51c9c350b
# ╠═ae92fd2f-cf70-477f-9da9-861ae7ef6bad
# ╠═f249f1a0-f11c-446b-b91e-a63a55df45ef
# ╠═4bb61ea6-1b71-4d94-bdd2-58b8c016f171
# ╠═d415634d-1ea9-435a-8de5-4b7a2350cd17
# ╠═d6f94de5-1457-426f-875a-35f8031bfafc
# ╠═8c14d493-f5ef-4f82-9970-8369acf181a7
# ╠═4ad77bb4-ea2c-4f2d-86a7-badb5b9fac9c
# ╠═a8b1c93c-30f6-4587-a5e3-6a5d73aee85d
# ╠═bee5fe62-691b-4a84-9aae-a4c90260af96
# ╠═21cf6e63-16e7-4d8c-8f0f-6db068b600ed
# ╠═ef4c561e-89c4-42e2-a169-f30a5bbe0871
# ╠═b4323785-5a16-41ed-954b-effbec5002b9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
