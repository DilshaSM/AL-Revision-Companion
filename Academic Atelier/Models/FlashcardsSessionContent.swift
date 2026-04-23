import Foundation

struct FlashcardsSessionContent: Hashable {
    var id: String
    var topicTitle: String
    var cards: [Card]

    static func placeholder(forTopicID topicID: String) -> FlashcardsSessionContent? {
        placeholderDecksByTopicID[topicID]
    }

    private static let placeholderDecksByTopicID: [String: FlashcardsSessionContent] = [
        "reaction-mechanisms": .init(
            id: "reaction-mechanisms",
            topicTitle: "Reaction Mechanisms",
            cards: [
                .init(id: "nucleophile", frontLabel: "TERM", frontText: "Nucleophile", backText: "An electron-pair donor that attacks electron-deficient centers."),
                .init(id: "electrophile", frontLabel: "TERM", frontText: "Electrophile", backText: "An electron-pair acceptor that is attracted to electron-rich species."),
                .init(id: "heterolytic", frontLabel: "TERM", frontText: "Heterolytic Fission", backText: "Bond breaking where both bonding electrons go to one atom, forming ions.")
            ]
        ),
        "cell-division": .init(
            id: "cell-division",
            topicTitle: "Cell Division",
            cards: [
                .init(id: "mitosis", frontLabel: "TERM", frontText: "Mitosis", backText: "Division producing two genetically identical daughter cells for growth and repair."),
                .init(id: "meiosis", frontLabel: "TERM", frontText: "Meiosis", backText: "Division that halves chromosome number and produces genetically varied gametes."),
                .init(id: "chromatid", frontLabel: "TERM", frontText: "Chromatid", backText: "One of the two identical copies formed when a chromosome replicates.")
            ]
        ),
        "integration-techniques": .init(
            id: "integration-techniques",
            topicTitle: "Integration Techniques",
            cards: [
                .init(id: "integration-by-parts", frontLabel: "METHOD", frontText: "Integration by Parts", backText: "A method based on reversing the product rule: ∫u dv = uv - ∫v du."),
                .init(id: "substitution", frontLabel: "METHOD", frontText: "Substitution", backText: "A method that simplifies an integral by replacing a complex expression with a new variable."),
                .init(id: "partial-fractions", frontLabel: "METHOD", frontText: "Partial Fractions", backText: "A technique for decomposing rational expressions into simpler fractions before integrating.")
            ]
        ),
        "newtons-laws": .init(
            id: "newtons-laws",
            topicTitle: "Newton's Laws",
            cards: [
                .init(id: "first-law", frontLabel: "LAW", frontText: "Newton's First Law", backText: "An object remains at rest or in uniform motion unless acted on by a resultant force."),
                .init(id: "second-law", frontLabel: "LAW", frontText: "Newton's Second Law", backText: "The net force on a body equals mass times acceleration."),
                .init(id: "third-law", frontLabel: "LAW", frontText: "Newton's Third Law", backText: "For every action, there is an equal and opposite reaction.")
            ]
        ),
        "organic-basics": .init(
            id: "organic-basics",
            topicTitle: "Organic Basics",
            cards: [
                .init(id: "functional-group", frontLabel: "TERM", frontText: "Functional Group", backText: "An atom or group of atoms responsible for the characteristic reactions of a compound."),
                .init(id: "homologous-series", frontLabel: "TERM", frontText: "Homologous Series", backText: "A family of organic compounds with the same functional group and general formula."),
                .init(id: "isomerism", frontLabel: "TERM", frontText: "Isomerism", backText: "Compounds with the same molecular formula but different structural arrangements.")
            ]
        ),
        "wave-optics": .init(
            id: "wave-optics",
            topicTitle: "Wave Optics",
            cards: [
                .init(id: "interference", frontLabel: "TERM", frontText: "Interference", backText: "Superposition of waves that produces regions of reinforcement and cancellation."),
                .init(id: "diffraction", frontLabel: "TERM", frontText: "Diffraction", backText: "Bending and spreading of waves when they pass through a gap or around an obstacle."),
                .init(id: "coherent-sources", frontLabel: "TERM", frontText: "Coherent Sources", backText: "Sources that emit waves with a constant phase difference and the same frequency.")
            ]
        )
    ]
}

extension FlashcardsSessionContent {
    struct Card: Identifiable, Hashable {
        var id: String
        var frontLabel: String
        var frontText: String
        var backText: String
        var hintText: String = "Recall the definition before revealing."
    }
}
