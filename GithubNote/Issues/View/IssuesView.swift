//
//  IssuesView.swift
//  GithubNote
//
//  Created by xs0521 on 2024/4/5.
//

import Foundation
import SwiftUI

typealias IssuesViewItemTapCallBack = () -> ()

struct IssuesView: View {
    
    @Binding var model: IssuesModel
    var tapCallBack: IssuesViewItemTapCallBack
    
    @State private var issuesHeight: CGFloat = AppConst.issueItemHeight * 2
    @State private var isIssuesloading: Bool = true
    @State private var isCreateIssue: Bool = false
    @State private var createString: String = ""
    
    var body: some View {
        ZStack {
            if !isCreateIssue {
                VStack (alignment: .center) {
                    Spacer()
                    List(model.issueList) { item in
                        VStack () {
                            Text(item.title?.toTitle() ?? "")
                                .foregroundStyle(item.id == model.selectedSideBarItem.id ? Color.black : Color.gray)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .multilineTextAlignment(.leading)
                        .frame(width: 200, height: AppConst.issueItemHeight)
                        .background(Color.clear)
                        .onTapGesture {
                            if item.id != model.selectedSideBarItem.id {
                                tapCallBack()
                                model.selectedSideBarItem = item
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.hidden)
                    .padding(EdgeInsets())
                    .frame(height: issuesHeight, alignment: .leading)
                    
                    if model.issueList.isEmpty && !isIssuesloading {
                        VStack {
                            Image(systemName: EmptyModel.figureArray.randomElement() ?? "")
                                .font(.system(size: 30))
                        }
                        .padding(.bottom, 60)
                    }
                    
                    if isIssuesloading {
                        ProgressView()
                            .padding(.bottom, 60)
                    }
                    
                    Spacer()
                }
                .frame(minWidth: 60, maxWidth: 200, alignment: .leading)
            }
            if isCreateIssue {
                IssuesCreateView(content: $createString)
            }
            VStack {
                Spacer()
                HStack {
                    Button {
                        if isCreateIssue == false {
                            isCreateIssue = true
                            return
                        }
                        Request.createIssue(title: createString, completion: { res in
                            guard let issue = res else { return }
                            DispatchQueue.main.async(execute: {
                                isCreateIssue = false
                                createString = ""
                                model.issueList.insert(issue, at: 0)
                                issuesHeight = CGFloat(model.issueList.count) * AppConst.issueItemHeight
                            })
                        })
                        
                    } label: {
                        Image(systemName: isCreateIssue ? "arrow.up.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 40))
                    }
                    if isCreateIssue {
                        Button {
                            isCreateIssue = false
                        } label: {
                            Image(systemName: "multiply.circle.fill")
                                .font(.system(size: 40))
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 20)
            }
        }
        .onAppear(perform: {
            isIssuesloading = true
            Request.getRepoIssueData { list in
                DispatchQueue.main.async(execute: {
                    model.issueList = list
                    issuesHeight = CGFloat(list.count) * AppConst.issueItemHeight
                    model.selectedSideBarItem = list.first ?? Issue()
                    isIssuesloading = false
                })
            }
        })
    }
}