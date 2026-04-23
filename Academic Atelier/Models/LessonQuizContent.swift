import Foundation

struct LessonQuizContent: Hashable {
    var id: String
    var subjectTitle: String
    var lessonTitle: String
    var questions: [Question]
    var resumeQuestionIndex: Int

    static func placeholder(
        forSubjectID subjectID: String,
        subjectTitle: String,
        lesson: SubjectLessonsContent.Lesson
    ) -> LessonQuizContent? {
        guard lesson.isAccessible else { return nil }

        let questions = questionBank(for: lesson, subjectTitle: subjectTitle)
        guard !questions.isEmpty else { return nil }

        let resumeQuestionIndex = clampedResumeIndex(for: lesson.state, totalQuestions: questions.count)
        let hydratedQuestions = questions.enumerated().map { index, question in
            var question = question
            if index <= resumeQuestionIndex {
                question.selectedOptionID = question.correctOptionID
            }
            return question
        }

        return .init(
            id: "\(subjectID)-\(lesson.id)",
            subjectTitle: subjectTitle,
            lessonTitle: lesson.title,
            questions: hydratedQuestions,
            resumeQuestionIndex: resumeQuestionIndex
        )
    }
}

extension LessonQuizContent {
    struct Question: Identifiable, Hashable {
        var id: String
        var prompt: String
        var options: [Option]
        var correctOptionID: String
        var selectedOptionID: String?
    }

    struct Option: Identifiable, Hashable {
        var id: String
        var text: String
    }
}

private extension LessonQuizContent {
    static func clampedResumeIndex(for state: SubjectLessonsContent.State, totalQuestions: Int) -> Int {
        guard totalQuestions > 0 else { return 0 }

        switch state {
        case .completed:
            return totalQuestions - 1
        case let .inProgress(progress, _):
            let nextIndex = Int(Double(totalQuestions) * progress) + 1
            return min(max(nextIndex, 0), totalQuestions - 1)
        case .locked:
            return 0
        }
    }

    static func questionBank(
        for lesson: SubjectLessonsContent.Lesson,
        subjectTitle: String
    ) -> [Question] {
        switch lesson.id {
        case "trig-functions-2":
            return trigonometryQuestions()
        case "ionic-covalent":
            return chemicalBondingQuestions()
        case "wave-particle":
            return waveParticleQuestions()
        default:
            return genericQuestions(for: lesson.title, subjectTitle: subjectTitle, lessonID: lesson.id)
        }
    }

    static func trigonometryQuestions() -> [Question] {
        [
            question(
                id: "trig-01",
                prompt: "If sin θ = 3/5 and θ is acute, what is cos θ?",
                options: ["4/5", "5/4", "3/4", "2/5"],
                correctIndex: 0
            ),
            question(
                id: "trig-02",
                prompt: "Which identity is always true for every angle θ?",
                options: ["sin²θ + cos²θ = 1", "tan²θ + cot²θ = 1", "sin θ + cos θ = 1", "sec θ - tan θ = 1"],
                correctIndex: 0
            ),
            question(
                id: "trig-03",
                prompt: "What is the period of y = tan x?",
                options: ["π", "2π", "π/2", "4π"],
                correctIndex: 0
            ),
            question(
                id: "trig-04",
                prompt: "If tan θ = 1, which acute angle satisfies the equation?",
                options: ["45°", "30°", "60°", "90°"],
                correctIndex: 0
            ),
            question(
                id: "trig-05",
                prompt: "Which expression is equivalent to sec θ?",
                options: ["1 / cos θ", "1 / sin θ", "cos θ / sin θ", "sin θ / cos θ"],
                correctIndex: 0
            ),
            question(
                id: "trig-06",
                prompt: "If sin θ = 1/2 in quadrant II, what is θ?",
                options: ["150°", "30°", "210°", "330°"],
                correctIndex: 0
            ),
            question(
                id: "trig-07",
                prompt: "What is the amplitude of y = 4 sin x?",
                options: ["4", "2", "π", "8"],
                correctIndex: 0
            ),
            question(
                id: "trig-08",
                prompt: "If cos 2x = 1 - 2 sin²x, which formula is being used?",
                options: ["Double-angle identity", "Pythagorean identity", "Sum-to-product identity", "Compound-angle identity"],
                correctIndex: 0
            ),
            question(
                id: "trig-09",
                prompt: "What is the exact value of sin 45°?",
                options: ["√2 / 2", "1 / 2", "√3 / 2", "1"],
                correctIndex: 0
            ),
            question(
                id: "trig-10",
                prompt: "Which interval contains the principal value of arcsin x?",
                options: ["[-π/2, π/2]", "[0, 2π]", "[0, π]", "[-π, π]"],
                correctIndex: 0
            ),
            question(
                id: "trig-11",
                prompt: "If tan θ = sin θ / cos θ, what happens when cos θ = 0?",
                options: ["tan θ is undefined", "tan θ becomes 0", "tan θ becomes 1", "tan θ equals sin θ"],
                correctIndex: 0
            ),
            question(
                id: "trig-12",
                prompt: "What is the range of y = 2 cos x - 1?",
                options: ["[-3, 1]", "[-1, 3]", "[-2, 2]", "[0, 2]"],
                correctIndex: 0
            ),
            question(
                id: "trig-13",
                prompt: "Which function has vertical asymptotes at x = π/2 + kπ?",
                options: ["tan x", "sin x", "cos x", "csc x"],
                correctIndex: 0
            ),
            question(
                id: "trig-14",
                prompt: "If sec θ = 2 and θ is acute, what is cos θ?",
                options: ["1/2", "2", "√3 / 2", "2 / √3"],
                correctIndex: 0
            ),
            question(
                id: "trig-15",
                prompt: "Which inverse trigonometric function returns an angle whose tangent is x?",
                options: ["arctan x", "arccos x", "arcsin x", "arcsec x"],
                correctIndex: 0
            )
        ]
    }

    static func chemicalBondingQuestions() -> [Question] {
        [
            question(
                id: "bond-01",
                prompt: "Which type of bonding involves the transfer of electrons from one atom to another?",
                options: ["Ionic bonding", "Covalent bonding", "Metallic bonding", "Hydrogen bonding"],
                correctIndex: 0
            ),
            question(
                id: "bond-02",
                prompt: "What is formed when sodium loses one electron?",
                options: ["Na⁺ ion", "Na⁻ ion", "Neutral sodium atom", "A covalent pair"],
                correctIndex: 0
            ),
            question(
                id: "bond-03",
                prompt: "In a covalent bond, the bonded atoms mainly do what with electrons?",
                options: ["Share electron pairs", "Transfer electrons completely", "Remove protons", "Absorb neutrons"],
                correctIndex: 0
            ),
            question(
                id: "bond-04",
                prompt: "Which compound is typically used as an example of ionic bonding?",
                options: ["Sodium chloride", "Methane", "Oxygen gas", "Graphite"],
                correctIndex: 0
            ),
            question(
                id: "bond-05",
                prompt: "Why do ionic compounds usually have high melting points?",
                options: ["Strong electrostatic attraction between ions", "Weak forces between molecules", "Low molecular mass", "They contain free electrons"],
                correctIndex: 0
            ),
            question(
                id: "bond-06",
                prompt: "Which particle arrangement best describes a metallic lattice?",
                options: ["Positive ions in a sea of delocalized electrons", "Neutral molecules held by hydrogen bonds", "Negative ions packed around atoms", "Atoms joined only by shared proton pairs"],
                correctIndex: 0
            ),
            question(
                id: "bond-07",
                prompt: "What gives metals their electrical conductivity?",
                options: ["Mobile delocalized electrons", "Fixed covalent bonds", "Low density", "Neutral ions"],
                correctIndex: 0
            ),
            question(
                id: "bond-08",
                prompt: "Which of the following is a simple molecular covalent substance?",
                options: ["Carbon dioxide", "Sodium oxide", "Magnesium chloride", "Copper"],
                correctIndex: 0
            ),
            question(
                id: "bond-09",
                prompt: "What kind of bond is present between the oxygen and hydrogen atoms in water molecules?",
                options: ["Polar covalent bond", "Ionic bond", "Metallic bond", "Coordinate proton bond"],
                correctIndex: 0
            ),
            question(
                id: "bond-10",
                prompt: "Which statement about giant covalent structures is correct?",
                options: ["They contain many atoms joined by strong covalent bonds", "They conduct because of moving ions in solid state", "They melt easily because of weak bonding", "They always dissolve in water"],
                correctIndex: 0
            ),
            question(
                id: "bond-11",
                prompt: "Why can graphite conduct electricity?",
                options: ["It has delocalized electrons between layers", "It contains ionic bonds", "Its carbon atoms are neutral molecules", "It has freely moving protons"],
                correctIndex: 0
            ),
            question(
                id: "bond-12",
                prompt: "Which property is most typical of simple covalent substances?",
                options: ["Low boiling point", "High electrical conductivity as solids", "Very high melting point", "Malleability"],
                correctIndex: 0
            ),
            question(
                id: "bond-13",
                prompt: "What is the main reason oppositely charged ions attract?",
                options: ["Electrostatic force", "Magnetic force", "Nuclear force", "Gravitational force"],
                correctIndex: 0
            ),
            question(
                id: "bond-14",
                prompt: "Which structure best explains the hardness of diamond?",
                options: ["A rigid giant covalent network", "Layers with weak intermolecular forces", "Free-moving ions in water", "Individual molecules with weak bonds"],
                correctIndex: 0
            ),
            question(
                id: "bond-15",
                prompt: "Which bonding model best explains why metals can be hammered into shape?",
                options: ["Layers of ions can slide while delocalized electrons maintain attraction", "Covalent molecules rotate freely", "Ions are fixed and brittle", "Atoms lose all valence electrons permanently"],
                correctIndex: 0
            )
        ]
    }

    static func waveParticleQuestions() -> [Question] {
        [
            question(
                id: "wave-01",
                prompt: "Which experiment showed that light can behave like a wave through interference?",
                options: ["Young's double-slit experiment", "Millikan oil-drop experiment", "Rutherford scattering", "Cavendish experiment"],
                correctIndex: 0
            ),
            question(
                id: "wave-02",
                prompt: "Which phenomenon best demonstrates the particle nature of light?",
                options: ["Photoelectric effect", "Diffraction", "Refraction", "Polarization"],
                correctIndex: 0
            ),
            question(
                id: "wave-03",
                prompt: "What is the energy of a photon proportional to?",
                options: ["Its frequency", "Its wavelength squared", "Its speed in vacuum", "Its amplitude only"],
                correctIndex: 0
            ),
            question(
                id: "wave-04",
                prompt: "Which equation relates the momentum of a particle to its wavelength?",
                options: ["λ = h / p", "E = mc²", "F = ma", "v = fλ"],
                correctIndex: 0
            ),
            question(
                id: "wave-05",
                prompt: "Who proposed that matter can have wave-like properties?",
                options: ["Louis de Broglie", "Isaac Newton", "Niels Bohr", "James Clerk Maxwell"],
                correctIndex: 0
            ),
            question(
                id: "wave-06",
                prompt: "What happens in the photoelectric effect when the incident frequency is below threshold?",
                options: ["No electrons are emitted", "Electrons gain more momentum", "The light speed decreases", "The metal becomes positively charged immediately"],
                correctIndex: 0
            ),
            question(
                id: "wave-07",
                prompt: "Which quantity determines whether light can eject electrons from a metal surface?",
                options: ["Frequency", "Intensity alone", "Distance from source", "Angle of incidence only"],
                correctIndex: 0
            ),
            question(
                id: "wave-08",
                prompt: "Why do electrons show diffraction patterns in experiments?",
                options: ["They have wave-like behavior", "They lose charge at high speed", "They turn into photons", "They move only in circles"],
                correctIndex: 0
            ),
            question(
                id: "wave-09",
                prompt: "If the momentum of a particle increases, what happens to its de Broglie wavelength?",
                options: ["It decreases", "It increases", "It stays constant", "It becomes zero immediately"],
                correctIndex: 0
            ),
            question(
                id: "wave-10",
                prompt: "Which statement best summarizes wave-particle duality?",
                options: ["Matter and radiation can show both wave and particle properties", "Only light behaves as both wave and particle", "Particles behave as waves only at rest", "Waves become particles only in mirrors"],
                correctIndex: 0
            ),
            question(
                id: "wave-11",
                prompt: "What is the work function of a metal?",
                options: ["Minimum energy needed to remove an electron", "Average kinetic energy of emitted electrons", "Frequency of emitted electrons", "Charge needed to ionize the lattice"],
                correctIndex: 0
            ),
            question(
                id: "wave-12",
                prompt: "Which variable most directly increases the kinetic energy of emitted photoelectrons once threshold is exceeded?",
                options: ["Increasing the frequency of the incident light", "Increasing the area of the metal", "Increasing the room temperature slightly", "Reducing the current in the circuit"],
                correctIndex: 0
            ),
            question(
                id: "wave-13",
                prompt: "Which unit is commonly used for photon energy in atomic-scale problems?",
                options: ["Electron volt", "Newton", "Pascal", "Tesla"],
                correctIndex: 0
            ),
            question(
                id: "wave-14",
                prompt: "What does interference require from the sources producing the waves?",
                options: ["A constant phase relationship", "A very high temperature", "Different speeds in vacuum", "Opposite charges"],
                correctIndex: 0
            ),
            question(
                id: "wave-15",
                prompt: "Which conclusion did the photoelectric effect strongly support?",
                options: ["Light energy is quantized into photons", "Light travels slower than electrons", "Metals contain no free electrons", "Waves cannot transfer energy"],
                correctIndex: 0
            )
        ]
    }

    static func genericQuestions(
        for lessonTitle: String,
        subjectTitle: String,
        lessonID: String
    ) -> [Question] {
        let prompts: [(String, [String], Int)] = [
            (
                "Which statement best describes the core concept of \(lessonTitle)?",
                [
                    "A key idea you are expected to recall accurately",
                    "An unrelated lab safety rule",
                    "A formula used only in another subject",
                    "A topic that belongs to a later module"
                ],
                0
            ),
            (
                "When revising \(lessonTitle), what should you identify first?",
                [
                    "The main principle and its definition",
                    "Only the most difficult calculation",
                    "A random worked example",
                    "A diagram without labels"
                ],
                0
            ),
            (
                "Which exam strategy fits \(lessonTitle) best?",
                [
                    "Recognize the pattern before choosing a method",
                    "Memorize the longest answer choice",
                    "Skip every conceptual question",
                    "Avoid checking units or notation"
                ],
                0
            ),
            (
                "What is the most useful outcome of repeated practice in \(lessonTitle)?",
                [
                    "Faster recognition of familiar question patterns",
                    "Forgetting earlier concepts immediately",
                    "Needing more steps for every question",
                    "Removing the need to show working"
                ],
                0
            ),
            (
                "Which detail is usually most important to track in \(lessonTitle)?",
                [
                    "The condition that tells you which rule applies",
                    "The font style used in the worksheet",
                    "The order of pages in the textbook",
                    "The date the topic was assigned"
                ],
                0
            ),
            (
                "A student revising \(lessonTitle) should usually start by doing what?",
                [
                    "Reviewing the underlying rule before solving questions",
                    "Jumping to the marking scheme without reading the prompt",
                    "Ignoring all worked examples",
                    "Changing the notation into a new personal system"
                ],
                0
            ),
            (
                "Which kind of mistake is most common when learners rush through \(lessonTitle)?",
                [
                    "Applying a familiar rule in the wrong situation",
                    "Using too much rough work",
                    "Writing the subject name incorrectly",
                    "Leaving extra space between steps"
                ],
                0
            ),
            (
                "Why is spaced practice useful for \(lessonTitle)?",
                [
                    "It improves retention and recall under exam pressure",
                    "It guarantees the same question will appear",
                    "It removes the need for conceptual understanding",
                    "It shortens every question automatically"
                ],
                0
            ),
            (
                "Which prompt most likely belongs to a \(subjectTitle) quiz on \(lessonTitle)?",
                [
                    "Apply the concept correctly to a new example",
                    "List every topic in the syllabus alphabetically",
                    "Name the school timetable for the week",
                    "Describe your revision desk setup"
                ],
                0
            ),
            (
                "What should a strong answer in \(lessonTitle) normally include?",
                [
                    "Correct reasoning, not just the final result",
                    "Only the shortest possible statement",
                    "A copied sentence from memory with no context",
                    "An unrelated formula from another unit"
                ],
                0
            ),
            (
                "Which habit improves performance in \(lessonTitle) over time?",
                [
                    "Reviewing errors and correcting the underlying idea",
                    "Repeating the same mistake without checking it",
                    "Skipping every question that looks unfamiliar",
                    "Answering from memory without reading carefully"
                ],
                0
            ),
            (
                "What is the best signal that a learner understands \(lessonTitle)?",
                [
                    "They can explain why a method works in a new context",
                    "They only recognize the title of the topic",
                    "They avoid questions with words",
                    "They rely on one memorized answer format"
                ],
                0
            ),
            (
                "Which revision resource is most helpful right before a quiz on \(lessonTitle)?",
                [
                    "A concise summary plus mixed practice questions",
                    "A blank notebook page with no prompts",
                    "An unrelated chapter from another subject",
                    "Only the final score from a previous test"
                ],
                0
            ),
            (
                "If a question on \(lessonTitle) looks unfamiliar, what is the best first step?",
                [
                    "Break it into known concepts and identify the pattern",
                    "Assume it belongs to a different subject",
                    "Ignore the given information completely",
                    "Write the answer choice with the longest wording"
                ],
                0
            ),
            (
                "What should backend progress on a \(lessonTitle) quiz represent?",
                [
                    "How far the learner has progressed through the question set",
                    "How many fonts were used in the UI",
                    "How often the tab bar was opened",
                    "How many times the app launched that day"
                ],
                0
            )
        ]

        return prompts.enumerated().map { index, item in
            question(
                id: "\(lessonID)-\(index + 1)",
                prompt: item.0,
                options: item.1,
                correctIndex: item.2
            )
        }
    }

    static func question(
        id: String,
        prompt: String,
        options: [String],
        correctIndex: Int
    ) -> Question {
        let optionValues = options.enumerated().map { index, title in
            Option(id: "\(id)-option-\(index)", text: title)
        }

        return .init(
            id: id,
            prompt: prompt,
            options: optionValues,
            correctOptionID: optionValues[correctIndex].id,
            selectedOptionID: nil
        )
    }
}

