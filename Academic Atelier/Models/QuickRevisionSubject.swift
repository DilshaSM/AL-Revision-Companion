import Foundation

struct QuickRevisionSubject: Identifiable, Hashable {
    var id: String
    var title: String
    var materialSubtitle: String
    var symbolName: String
    var topicsSectionTitle: String
    var topics: [Topic]
    var recentlyOpenedTitle: String
    var recentlyOpened: [RecentTopic]

    static let placeholders: [QuickRevisionSubject] = [
        .init(
            id: "combined-maths",
            title: "Combined Mathematics",
            materialSubtitle: "Key Notes",
            symbolName: "function",
            topicsSectionTitle: "All Combined Mathematics Topics",
            topics: [
                .init(
                    id: "limits",
                    title: "Limits and Continuity",
                    subtitle: "Core Concepts",
                    symbolName: "sum",
                    content: .init(
                        overview: "Core limit laws and continuity rules for fast revision.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Limit", detail: "The value a function approaches as the input approaches a point."),
                            .init(title: "Continuity", detail: "A function is continuous if left limit, right limit, and function value are equal."),
                            .init(title: "Indeterminate Form", detail: "Expressions like 0/0 that require algebraic simplification before evaluation.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Limit Law", expression: "lim (f + g) = lim f + lim g"),
                            .init(label: "Continuity Test", expression: "lim f(x) = f(a)")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Algebraic Simplification", detail: "Factorisation or rationalisation can remove undefined forms."),
                            .init(title: "Continuity Rule", detail: "Polynomials and rational functions are continuous on their valid domains.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Check left-hand and right-hand limits before claiming continuity.",
                            "Use factorisation or conjugates to resolve 0/0 cases.",
                            "Remember domain restrictions when evaluating rational functions."
                        ]
                    )
                ),
                .init(
                    id: "differentiation",
                    title: "Differentiation",
                    subtitle: "Rules & Applications",
                    symbolName: "function",
                    content: .init(
                        overview: "Derivative rules, gradients, and rate-of-change facts in one place.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Derivative", detail: "Instantaneous rate of change of a function with respect to a variable."),
                            .init(title: "Stationary Point", detail: "A point where the derivative is zero."),
                            .init(title: "Gradient", detail: "The slope of the tangent line to the curve.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Power Rule", expression: "d/dx (x^n) = n x^(n-1)"),
                            .init(label: "Product Rule", expression: "(uv)' = u'v + uv'")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Linearity", detail: "Differentiate sums term by term."),
                            .init(title: "Tangency", detail: "The derivative gives the slope of the tangent at a point.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Use power, product, quotient, and chain rules systematically.",
                            "At maxima and minima, first derivative is zero but second derivative confirms nature.",
                            "Interpret derivatives as both slope and physical rate of change."
                        ]
                    )
                ),
                .init(
                    id: "integration",
                    title: "Integration",
                    subtitle: "Formula Sheet",
                    symbolName: "chart.xyaxis.line",
                    content: .init(
                        overview: "Essential antiderivatives and area-under-curve reminders.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Integral", detail: "Reverse process of differentiation used to recover a function."),
                            .init(title: "Constant of Integration", detail: "An arbitrary constant added in indefinite integration."),
                            .init(title: "Definite Integral", detail: "Represents signed area between a curve and the x-axis.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Power Rule", expression: "∫ x^n dx = x^(n+1)/(n+1)"),
                            .init(label: "Area", expression: "A = ∫[a,b] f(x) dx")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Reverse Differentiation", detail: "Every integration step should be checked by differentiating the result."),
                            .init(title: "Signed Area", detail: "Areas below the x-axis contribute negatively to a definite integral.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Always append + C in indefinite integration.",
                            "Split complicated expressions before integrating when possible.",
                            "Use limits carefully for definite integrals."
                        ]
                    )
                ),
                .init(
                    id: "trigonometry",
                    title: "Trigonometric Functions",
                    subtitle: "Identities & Graphs",
                    symbolName: "waveform.path",
                    content: .init(
                        overview: "Fast recall of identities, graph behavior, and standard angles.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Periodic Function", detail: "A function that repeats its values at regular intervals."),
                            .init(title: "Amplitude", detail: "Maximum displacement from the midline."),
                            .init(title: "Identity", detail: "An equation true for all values in its domain.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Pythagorean Identity", expression: "sin²x + cos²x = 1"),
                            .init(label: "Double Angle", expression: "sin 2x = 2 sin x cos x")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Graph Shifts", detail: "Phase shifts and vertical translations change graph position, not core shape."),
                            .init(title: "Reference Angles", detail: "Use symmetry to evaluate trigonometric ratios in all quadrants.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Memorize standard values for 0°, 30°, 45°, 60°, and 90°.",
                            "Use identities to simplify before solving equations.",
                            "Check quadrant signs when evaluating exact values."
                        ]
                    )
                )
            ],
            recentlyOpenedTitle: "Recently Opened",
            recentlyOpened: [
                .init(id: "limits", title: "Limits", symbolName: "sum"),
                .init(id: "trigonometry", title: "Trigonometry", symbolName: "waveform.path")
            ]
        ),
        .init(
            id: "physics",
            title: "Physics",
            materialSubtitle: "Formula Sheet",
            symbolName: "bolt",
            topicsSectionTitle: "All Physics Topics",
            topics: [
                .init(
                    id: "motion-straight-line",
                    title: "Motion in a Straight Line",
                    subtitle: "Kinematics & Vectors",
                    symbolName: "ruler",
                    content: .init(
                        overview: "Core one-dimensional motion relationships for quick recall.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Displacement", detail: "Shortest directed distance from initial to final position."),
                            .init(title: "Velocity", detail: "Rate of change of displacement with time."),
                            .init(title: "Acceleration", detail: "Rate of change of velocity with time.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Uniform Acceleration", expression: "v = u + at"),
                            .init(label: "Displacement", expression: "s = ut + 1/2 at²")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Constant Acceleration Model", detail: "SUVAT equations apply only when acceleration is constant."),
                            .init(title: "Graph Interpretation", detail: "Slope of displacement-time gives velocity; slope of velocity-time gives acceleration.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Pick a sign convention before solving.",
                            "Use the equation without the unknown variable to reduce errors.",
                            "Interpret motion graphs before substituting values."
                        ]
                    )
                ),
                .init(
                    id: "newtons-laws",
                    title: "Newton’s Laws",
                    subtitle: "Force, Mass & Acceleration",
                    symbolName: "hammer",
                    content: .init(
                        overview: "Force diagrams and motion laws summarized for fast revision.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Inertia", detail: "Tendency of a body to resist changes to its state of motion."),
                            .init(title: "Net Force", detail: "Vector sum of all forces acting on an object."),
                            .init(title: "Momentum", detail: "Product of mass and velocity.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Second Law", expression: "F = ma"),
                            .init(label: "Weight", expression: "W = mg")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "First Law", detail: "An object remains at rest or moves uniformly unless acted on by a resultant force."),
                            .init(title: "Third Law", detail: "Action and reaction forces are equal in magnitude and opposite in direction.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Draw free-body diagrams before writing equations.",
                            "Resolve forces into components when motion is not one-dimensional.",
                            "Action-reaction pairs act on different bodies."
                        ]
                    )
                ),
                .init(
                    id: "thermodynamics",
                    title: "Thermodynamics",
                    subtitle: "Formula Sheet",
                    symbolName: "bolt",
                    content: .init(
                        overview: "Key definitions, formulas, and laws for fast review.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Zeroth Law", detail: "Systems in thermal equilibrium with a third system are in equilibrium with each other."),
                            .init(title: "Entropy (S)", detail: "Measure of thermal energy per unit temperature unavailable for useful work."),
                            .init(title: "Enthalpy (H)", detail: "Total heat content (internal energy + product of pressure and volume).")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "First Law", expression: "ΔU = Q - W"),
                            .init(label: "Entropy Change", expression: "dS = dQ / T")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "First Law of Thermodynamics", detail: "Energy conservation: Transformation only, no creation or destruction."),
                            .init(title: "Second Law of Thermodynamics", detail: "Total entropy of isolated systems never decreases; only stays constant or increases.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Focus on the heat-work-internal energy relationship.",
                            "Review Carnot efficiency and cycle mechanics.",
                            "Spontaneous processes always increase entropy."
                        ]
                    )
                ),
                .init(
                    id: "circular-motion",
                    title: "Circular Motion",
                    subtitle: "Key Definitions",
                    symbolName: "arrow.triangle.2.circlepath",
                    content: .init(
                        overview: "Angular motion, centripetal force, and period relationships at a glance.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Angular Velocity", detail: "Rate of change of angular displacement."),
                            .init(title: "Centripetal Acceleration", detail: "Acceleration directed toward the center of the circular path."),
                            .init(title: "Period", detail: "Time taken for one complete revolution.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Centripetal Force", expression: "F = mv² / r"),
                            .init(label: "Angular Speed", expression: "ω = 2π / T")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Center-Seeking Force", detail: "The resultant force must always point toward the center."),
                            .init(title: "Tangential Velocity", detail: "Velocity is tangent to the path even while acceleration points inward.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Do not confuse centripetal force with a new force type; it is the resultant inward force.",
                            "Use radians when relating angular and linear variables.",
                            "Remember velocity and acceleration are perpendicular in uniform circular motion."
                        ]
                    )
                )
            ],
            recentlyOpenedTitle: "Recently Opened",
            recentlyOpened: [
                .init(id: "thermodynamics", title: "Thermodynamics", symbolName: "bolt"),
                .init(id: "circular-motion", title: "Circular Motion", symbolName: "arrow.triangle.2.circlepath")
            ]
        ),
        .init(
            id: "chemistry",
            title: "Chemistry",
            materialSubtitle: "Quick Summary",
            symbolName: "flask",
            topicsSectionTitle: "All Chemistry Topics",
            topics: [
                .init(
                    id: "atomic-structure",
                    title: "Atomic Structure",
                    subtitle: "Key Concepts",
                    symbolName: "atom",
                    content: .init(
                        overview: "Particles, shells, and atomic models in a compact revision format.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Atomic Number", detail: "Number of protons in the nucleus."),
                            .init(title: "Mass Number", detail: "Total number of protons and neutrons."),
                            .init(title: "Isotopes", detail: "Atoms of the same element with different neutron numbers.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Neutron Count", expression: "n = A - Z"),
                            .init(label: "Relative Mass", expression: "Ar = Σ abundance × mass")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Shell Filling", detail: "Electrons occupy lower energy levels before higher ones."),
                            .init(title: "Nuclear Identity", detail: "The proton number determines the element.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Keep proton, neutron, and electron roles distinct.",
                            "Use isotopic notation to track atomic composition.",
                            "Electron arrangement explains chemical behavior."
                        ]
                    )
                ),
                .init(
                    id: "chemical-bonding",
                    title: "Chemical Bonding",
                    subtitle: "Definitions & Rules",
                    symbolName: "link",
                    content: .init(
                        overview: "Bond types and structure-property links for quick recall.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Ionic Bond", detail: "Electrostatic attraction between oppositely charged ions."),
                            .init(title: "Covalent Bond", detail: "Shared pair of electrons between atoms."),
                            .init(title: "Metallic Bond", detail: "Attraction between metal cations and delocalized electrons.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Formal Charge", expression: "FC = valence - lone - 1/2 bonding"),
                            .init(label: "Bond Order", expression: "BO = 1/2 (Nb - Na)")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Octet Rule", detail: "Atoms tend to attain stable noble-gas configurations."),
                            .init(title: "Structure and Property", detail: "Bonding type influences melting point, conductivity, and hardness.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Classify the bond before predicting properties.",
                            "Use electronegativity difference to reason about polarity.",
                            "Remember giant covalent structures behave differently from simple molecules."
                        ]
                    )
                ),
                .init(
                    id: "organic-reactions",
                    title: "Organic Reactions",
                    subtitle: "Mechanism Summary",
                    symbolName: "drop",
                    content: .init(
                        overview: "Reaction patterns and mechanism cues for fast revision.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Electrophile", detail: "Species that accepts an electron pair."),
                            .init(title: "Nucleophile", detail: "Species that donates an electron pair."),
                            .init(title: "Homolytic Fission", detail: "Bond breaking where each atom gets one electron.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "General Alkane", expression: "CₙH₂ₙ₊₂"),
                            .init(label: "General Alkene", expression: "CₙH₂ₙ")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Mechanism Type", detail: "Substitution, addition, and elimination depend on reactants and conditions."),
                            .init(title: "Curly Arrows", detail: "Arrows show electron-pair movement, not atom movement.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Identify the reactive site before picking the mechanism.",
                            "Use reagents and conditions to distinguish substitution from elimination.",
                            "Track electron flow carefully in every step."
                        ]
                    )
                ),
                .init(
                    id: "equilibrium",
                    title: "Chemical Equilibrium",
                    subtitle: "Important Equations",
                    symbolName: "arrow.left.arrow.right",
                    content: .init(
                        overview: "Dynamic equilibrium and Le Chatelier reminders for rapid review.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Dynamic Equilibrium", detail: "Forward and reverse reactions occur at equal rates."),
                            .init(title: "Equilibrium Constant", detail: "Ratio of product and reactant terms at equilibrium."),
                            .init(title: "Le Chatelier Principle", detail: "A system shifts to oppose an applied change.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Equilibrium Constant", expression: "Kc = [products] / [reactants]"),
                            .init(label: "Reaction Quotient", expression: "Qc = [products] / [reactants]")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Temperature Effect", detail: "Only temperature changes the value of Kc."),
                            .init(title: "Catalyst Effect", detail: "Catalysts speed up both directions equally without shifting equilibrium position.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Compare Qc with Kc to predict the shift direction.",
                            "Pressure changes matter only for gaseous systems with unequal mole counts.",
                            "Keep concentration terms consistent when writing Kc."
                        ]
                    )
                )
            ],
            recentlyOpenedTitle: "Recently Opened",
            recentlyOpened: [
                .init(id: "organic-reactions", title: "Organic Reactions", symbolName: "drop"),
                .init(id: "equilibrium", title: "Equilibrium", symbolName: "arrow.left.arrow.right")
            ]
        ),
        .init(
            id: "biology",
            title: "Biology",
            materialSubtitle: "Key Definitions",
            symbolName: "leaf",
            topicsSectionTitle: "All Biology Topics",
            topics: [
                .init(
                    id: "cell-biology",
                    title: "Cell Biology",
                    subtitle: "Structures & Functions",
                    symbolName: "circle.grid.2x2",
                    content: .init(
                        overview: "Membrane, organelle, and transport basics for quick revision.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Organelle", detail: "Specialized structure within a cell that performs a specific function."),
                            .init(title: "Plasma Membrane", detail: "Selectively permeable boundary of the cell."),
                            .init(title: "Diffusion", detail: "Net movement of particles down a concentration gradient.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Magnification", expression: "M = image size / actual size"),
                            .init(label: "Surface Area Ratio", expression: "SA:V = surface area / volume")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Compartmentalization", detail: "Organelles improve efficiency by separating cellular processes."),
                            .init(title: "Membrane Transport", detail: "Passive transport follows gradients; active transport requires energy.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Match each organelle to its function.",
                            "Understand why SA:V affects cell efficiency.",
                            "Compare diffusion, osmosis, and active transport clearly."
                        ]
                    )
                ),
                .init(
                    id: "genetics",
                    title: "Genetics",
                    subtitle: "Inheritance Basics",
                    symbolName: "circle.hexagongrid",
                    content: .init(
                        overview: "Genes, alleles, and inheritance patterns in a short format.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Gene", detail: "A unit of heredity that codes for a characteristic."),
                            .init(title: "Allele", detail: "Alternative form of a gene."),
                            .init(title: "Genotype", detail: "Genetic makeup of an organism.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Monohybrid Ratio", expression: "3 : 1"),
                            .init(label: "Genotype Ratio", expression: "1 : 2 : 1")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Segregation", detail: "Allele pairs separate during gamete formation."),
                            .init(title: "Independent Assortment", detail: "Genes on different chromosomes assort independently.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Differentiate phenotype from genotype.",
                            "Use Punnett squares for inheritance probabilities.",
                            "Remember dominant alleles mask recessive ones only in heterozygotes."
                        ]
                    )
                ),
                .init(
                    id: "evolution",
                    title: "Evolution",
                    subtitle: "Theory Summary",
                    symbolName: "leaf.arrow.circlepath",
                    content: .init(
                        overview: "Selection, variation, and adaptation summarized briefly.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Natural Selection", detail: "Individuals with advantageous traits survive and reproduce more."),
                            .init(title: "Variation", detail: "Differences in characteristics among individuals."),
                            .init(title: "Adaptation", detail: "Inherited feature that improves survival or reproduction.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Allele Frequency", expression: "p + q = 1"),
                            .init(label: "Hardy-Weinberg", expression: "p² + 2pq + q² = 1")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Selection Pressure", detail: "Environmental factors drive changes in population traits."),
                            .init(title: "Common Ancestry", detail: "Shared structures and genes indicate evolutionary relationships.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Evolution acts on populations, not individuals.",
                            "Variation must be heritable for selection to matter.",
                            "Adaptations arise over generations through differential survival."
                        ]
                    )
                ),
                .init(
                    id: "ecology",
                    title: "Ecology",
                    subtitle: "Food Chains & Cycles",
                    symbolName: "tree",
                    content: .init(
                        overview: "Energy flow and ecosystem relationships at a glance.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Ecosystem", detail: "Community of organisms interacting with their physical environment."),
                            .init(title: "Trophic Level", detail: "Position occupied in a food chain."),
                            .init(title: "Biomass", detail: "Mass of living material in a given area or volume.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Transfer Efficiency", expression: "efficiency = output / input × 100"),
                            .init(label: "Population Growth", expression: "growth = births + immigration - deaths - emigration")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Energy Loss", detail: "Energy decreases at each trophic level due to heat and metabolism."),
                            .init(title: "Nutrient Cycling", detail: "Matter is recycled through biotic and abiotic components.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Distinguish food chains from food webs.",
                            "Energy flows one way while matter cycles.",
                            "Population size depends on limiting factors."
                        ]
                    )
                )
            ],
            recentlyOpenedTitle: "Recently Opened",
            recentlyOpened: [
                .init(id: "cell-biology", title: "Cell Biology", symbolName: "circle.grid.2x2"),
                .init(id: "ecology", title: "Ecology", symbolName: "tree")
            ]
        ),
        .init(
            id: "ict",
            title: "ICT",
            materialSubtitle: "Essential Concepts",
            symbolName: "desktopcomputer",
            topicsSectionTitle: "All ICT Topics",
            topics: [
                .init(
                    id: "computer-systems",
                    title: "Computer Systems",
                    subtitle: "Hardware & Software",
                    symbolName: "cpu",
                    content: .init(
                        overview: "Hardware, software, and system functions in a concise format.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Hardware", detail: "Physical components of a computer system."),
                            .init(title: "Software", detail: "Programs and instructions used by hardware."),
                            .init(title: "Operating System", detail: "Core system software that manages resources and applications.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Data Units", expression: "1 byte = 8 bits"),
                            .init(label: "Clock Speed", expression: "Hz = cycles / second")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Input-Process-Output", detail: "Computer systems accept data, process it, and generate output."),
                            .init(title: "Storage Hierarchy", detail: "Faster memory is smaller and more expensive than slower secondary storage.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Differentiate system software from application software.",
                            "Know the purpose of CPU, RAM, and secondary storage.",
                            "Use data units correctly when comparing memory sizes."
                        ]
                    )
                ),
                .init(
                    id: "networking",
                    title: "Networking",
                    subtitle: "Protocols & Models",
                    symbolName: "network",
                    content: .init(
                        overview: "Core network components and protocol concepts for revision.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Protocol", detail: "Set of rules that govern communication between devices."),
                            .init(title: "Router", detail: "Device that forwards packets between networks."),
                            .init(title: "Bandwidth", detail: "Maximum data transfer capacity of a connection.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Transmission Time", expression: "time = data size / rate"),
                            .init(label: "Bit Rate", expression: "rate = bits / second")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Layered Communication", detail: "Network tasks are divided across conceptual layers for reliability and interoperability."),
                            .init(title: "Packet Switching", detail: "Data is split into packets that may travel by different routes.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Match each device to its networking role.",
                            "Differentiate LAN, WAN, and the internet.",
                            "Remember protocols are needed at every stage of communication."
                        ]
                    )
                ),
                .init(
                    id: "databases",
                    title: "Databases",
                    subtitle: "Tables & Queries",
                    symbolName: "externaldrive",
                    content: .init(
                        overview: "Database structure, keys, and query essentials in one place.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "Field", detail: "A single attribute stored in a table."),
                            .init(title: "Primary Key", detail: "A field that uniquely identifies each record."),
                            .init(title: "Query", detail: "Request used to retrieve or manipulate data.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Selection", expression: "SELECT * FROM table"),
                            .init(label: "Condition", expression: "WHERE field = value")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Normalization", detail: "Organize data to reduce redundancy and update anomalies."),
                            .init(title: "Entity Integrity", detail: "Primary keys must be unique and not null.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Differentiate primary keys from foreign keys.",
                            "Think in rows, columns, and relationships.",
                            "Use queries to filter and sort information efficiently."
                        ]
                    )
                ),
                .init(
                    id: "web-technologies",
                    title: "Web Technologies",
                    subtitle: "Internet Basics",
                    symbolName: "globe",
                    content: .init(
                        overview: "Web structure, standards, and request-response basics for quick review.",
                        keyDefinitionsTitle: "Key Definitions",
                        keyDefinitions: [
                            .init(title: "URL", detail: "Address used to locate a resource on the web."),
                            .init(title: "HTTP", detail: "Protocol used to transfer web resources."),
                            .init(title: "Browser", detail: "Client software used to request and render web content.")
                        ],
                        formulasTitle: "Important Formulas",
                        formulas: [
                            .init(label: "Protocol Format", expression: "scheme://host/path"),
                            .init(label: "HTML Skeleton", expression: "<html><body>...</body></html>")
                        ],
                        lawsTitle: "Laws & Principles",
                        laws: [
                            .init(title: "Client-Server Model", detail: "Browsers request resources from servers and render the response."),
                            .init(title: "Separation of Concerns", detail: "HTML provides structure, CSS handles presentation, and scripts add behavior.")
                        ],
                        quickSummaryTitle: "Quick Summary",
                        summaryPoints: [
                            "Understand how a browser requests a page.",
                            "Keep URL structure and protocol roles clear.",
                            "Differentiate front-end presentation from back-end processing."
                        ]
                    )
                )
            ],
            recentlyOpenedTitle: "Recently Opened",
            recentlyOpened: [
                .init(id: "networking", title: "Networking", symbolName: "network"),
                .init(id: "databases", title: "Databases", symbolName: "externaldrive")
            ]
        )
    ]
}

extension QuickRevisionSubject {
    struct Topic: Identifiable, Hashable {
        var id: String
        var title: String
        var subtitle: String
        var symbolName: String
        var content: Content
    }

    struct RecentTopic: Identifiable, Hashable {
        var id: String
        var title: String
        var symbolName: String
    }

    struct Content: Hashable {
        var overview: String
        var keyDefinitionsTitle: String
        var keyDefinitions: [DefinitionItem]
        var formulasTitle: String
        var formulas: [FormulaItem]
        var lawsTitle: String
        var laws: [LawItem]
        var quickSummaryTitle: String
        var summaryPoints: [String]
    }

    struct DefinitionItem: Hashable {
        var title: String
        var detail: String
    }

    struct FormulaItem: Hashable {
        var label: String
        var expression: String
    }

    struct LawItem: Hashable {
        var title: String
        var detail: String
    }
}

extension QuickRevisionSubject {
    func topic(withID id: String) -> Topic? {
        topics.first { $0.id == id }
    }
}
