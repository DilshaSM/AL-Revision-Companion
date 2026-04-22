import SwiftUI

struct QuickRevisionContentView: View {
    @Environment(\.dismiss) private var dismiss

    private let topic: QuickRevisionSubject.Topic

    init(topic: QuickRevisionSubject.Topic) {
        self.topic = topic
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 44) {
                    headerSection
                    definitionsSection
                    formulasSection
                    lawsSection
                    summarySection
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 48)
            }
        }
        .background(QuickRevisionPalette.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension QuickRevisionContentView {
    var topBar: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(QuickRevisionPalette.topBarTint)

            Rectangle()
                .fill(.black.opacity(0.03))
                .frame(height: 0.5)
        }
        .frame(height: 96)
        .overlay(alignment: .leading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(QuickRevisionPalette.ink)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .padding(.leading, 28)
            .padding(.top, 48)
            .padding(.bottom, 16)
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(topic.title)
                .font(AppTypography.quickRevisionTopicTitle)
                .tracking(-0.9)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text(topic.content.overview)
                .font(AppTypography.quickRevisionContentSubtitle)
                .foregroundStyle(QuickRevisionPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var definitionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel(topic.content.keyDefinitionsTitle)

            VStack(spacing: 18) {
                ForEach(Array(topic.content.keyDefinitions.enumerated()), id: \.offset) { _, item in
                    DefinitionCard(item: item)
                }
            }
        }
    }

    var formulasSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel(topic.content.formulasTitle)

            VStack(spacing: 18) {
                ForEach(Array(topic.content.formulas.enumerated()), id: \.offset) { _, formula in
                    FormulaCard(formula: formula)
                }
            }
        }
    }

    var lawsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel(topic.content.lawsTitle)

            VStack(spacing: 18) {
                ForEach(Array(topic.content.laws.enumerated()), id: \.offset) { _, law in
                    LawCard(law: law)
                }
            }
        }
    }

    var summarySection: some View {
        VStack(alignment: .leading, spacing: 24) {
            sectionLabel(topic.content.quickSummaryTitle)

            VStack(alignment: .leading, spacing: 22) {
                ForEach(Array(topic.content.summaryPoints.enumerated()), id: \.offset) { _, point in
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(QuickRevisionPalette.brand)
                            .padding(.top, 2)

                        Text(point)
                            .font(AppTypography.quickRevisionSummaryBody)
                            .foregroundStyle(QuickRevisionPalette.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(QuickRevisionPalette.summaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(AppTypography.quickRevisionSectionLabel)
            .tracking(2.0)
            .foregroundStyle(QuickRevisionPalette.sectionLabel)
    }
}

private struct DefinitionCard: View {
    let item: QuickRevisionSubject.DefinitionItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.title)
                .font(AppTypography.quickRevisionDefinitionTitle)
                .foregroundStyle(QuickRevisionPalette.brand)

            Text(item.detail)
                .font(AppTypography.quickRevisionCardBody)
                .foregroundStyle(QuickRevisionPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct FormulaCard: View {
    let formula: QuickRevisionSubject.FormulaItem

    var body: some View {
        VStack(spacing: 18) {
            Text(formula.label.uppercased())
                .font(AppTypography.quickRevisionFormulaLabel)
                .tracking(1.2)
                .foregroundStyle(QuickRevisionPalette.brand)

            Text(formula.expression)
                .font(AppTypography.quickRevisionFormulaExpression)
                .foregroundStyle(QuickRevisionPalette.ink)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct LawCard: View {
    let law: QuickRevisionSubject.LawItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(law.title)
                .font(AppTypography.quickRevisionLawTitle)
                .foregroundStyle(QuickRevisionPalette.ink)

            Text(law.detail)
                .font(AppTypography.quickRevisionCardBody)
                .foregroundStyle(QuickRevisionPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 26)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
