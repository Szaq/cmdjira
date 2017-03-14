//
//  ResultsPage.swift
//  cmdjira
//
//  Created by Łukasz Kwoska on 16/03/2017.
//  Copyright © 2017 Spinal Development. All rights reserved.
//

import Foundation

protocol JSONDecodable {
    init(json: JSON)
}

struct ResultsPage<ResultType: JSONDecodable> {
    let page: Page
    let total: Int
    let results: [ResultType]

    var isLastPage: Bool { return page.startAt + results.count < total && results.count == page.maxResults}

    init(json: JSON, resultsFieldName: String) {
        page = Page(startAt: json["startAt"].intValue, maxResults: json["maxResults"].intValue)
        self.total = json["total"].intValue
        self.results = json[resultsFieldName].arrayValue.map { ResultType(json: $0)}
    }
}

func handlePagedResult<ResultType>(context: CommandContext,
                       page: Page = Page.default,
                       onLoad: @escaping (Page) -> Promise<Result<ResultsPage<ResultType>>>,
                       onPage: @escaping ([ResultType]) -> Void,
                       onDone: @escaping () -> Void,
                       onError: @escaping (Error) -> Void) {

    onLoad(page).then { result in

        switch result {
        case .success(let resultPage):

            onPage(resultPage.results)

            if resultPage.isLastPage {
                handlePagedResult(context: context,
                                  page: page.next(),
                                  onLoad: onLoad,
                                  onPage: onPage,
                                  onDone: onDone,
                                  onError: onError)
            } else {
                onDone()
            }

        case .failure(let error):
            onError(error)
        }
        }
        .addTo(disposeBag: context.disposeBag)
}
