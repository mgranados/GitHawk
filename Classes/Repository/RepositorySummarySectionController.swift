//
//  RepositorySummarySectionController.swift
//  Freetime
//
//  Created by Sherlock, James on 29/07/2017.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import IGListKit

final class RepositorySummarySectionController: ListSwiftSectionController<RepositoryIssueSummaryModel> {

    private let client: GithubClient
    private let owner: String
    private let repo: String

    init(client: GithubClient, owner: String, repo: String) {
        self.client = client
        self.owner = owner
        self.repo = repo
        super.init()
    }

    override func createBinders(from value: RepositoryIssueSummaryModel) -> [ListBinder] {
        return [
            binder(value, cellType: ListCellType.class(RepositorySummaryCell.self), size: {
                let width = $0.collection.safeContentWidth()
                let object = $0.value
                let labelListViewHeightAndSpacing: CGFloat = {
                    guard object.labels.count > 0 else { return 0 }
                    let labelListViewWidth = width - (Styles.Sizes.columnSpacing * 2)
                    let labelListViewHeight = LabelListView.height(
                        width: labelListViewWidth,
                        labels: object.labels,
                        cacheKey: object.labelSummary
                    )
                    return labelListViewHeight + Styles.Sizes.rowSpacing
                }()

                let height = object.title.viewSize(in: width).height
                    + Styles.Text.secondary.preferredFont.lineHeight
                    + Styles.Sizes.gutter
                    + labelListViewHeightAndSpacing
                return $0.collection.cellSize(with: ceil(height))
            },
                   configure: {
                    $0.configure($1.value)
            }, didSelect: { [weak self] context in
                guard let `self` = self else { return }
                let issueModel = IssueDetailsModel(
                    owner: self.owner,
                    repo: self.repo,
                    number: context.value.number
                )
                // resign keyboard if it was triggered to become active by SearchBar
                self.viewController?.view.endEditing(false)
                self.viewController?.route_push(to: IssuesViewController(
                    client: self.client,
                    model: issueModel
                ))
            })
        ]
    }

}
