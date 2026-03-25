import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Tree, NodeApi } from 'react-arborist';
import { useDispatch, useSelector } from 'react-redux';
import type { AppDispatch, RootState } from '@redux/index';
import type { Comment, Issue } from '@const/index';
import {
  updateSelectedIssue,
  updateSelectedComment,
  updateComments,
} from '@slice/content-slice';
import { getCommentTitle, formatTwitterTime } from '@util/index';
import * as db from '@db/index';

type TreeNode = {
  id: string;
  name: string;
  type: 'label' | 'issue' | 'comment';
  children?: TreeNode[];
  issue?: Issue;
  comment?: Comment;
};

function makeIssueNode(
  issue: Issue,
  issueComments: Record<string, Comment[]>,
): TreeNode {
  const loaded = issueComments[issue.id];
  return {
    id: `issue:${issue.id}`,
    name: issue.title,
    type: 'issue' as const,
    issue,
    children: loaded
      ? loaded.map((comment) => ({
          id: `comment:${comment.id || comment.uuid}`,
          name: getCommentTitle(comment.body) || 'New Note',
          type: 'comment' as const,
          comment,
        }))
      : [],
  };
}

function buildTree(
  issues: Issue[],
  issueComments: Record<string, Comment[]>,
): TreeNode[] {
  const labelMap = new Map<string, Issue[]>();
  let hasAnyLabel = false;

  issues.forEach((issue) => {
    if (issue.labels && issue.labels.length > 0) {
      hasAnyLabel = true;
      issue.labels.forEach((label) => {
        if (!labelMap.has(label.name)) labelMap.set(label.name, []);
        labelMap.get(label.name)!.push(issue);
      });
    } else {
      if (!labelMap.has('__none__')) labelMap.set('__none__', []);
      labelMap.get('__none__')!.push(issue);
    }
  });

  // No labels at all → flat list of issues without label folder wrapper
  if (!hasAnyLabel) {
    return issues.map((issue) => makeIssueNode(issue, issueComments));
  }

  const sorted = [...labelMap.entries()].sort(([a], [b]) => {
    if (a === '__none__') return 1;
    if (b === '__none__') return -1;
    return a.localeCompare(b);
  });

  return sorted.map(([key, labelIssues]) => ({
    id: `label:${key}`,
    name: key === '__none__' ? 'No Label' : key,
    type: 'label' as const,
    children: labelIssues.map((issue) => makeIssueNode(issue, issueComments)),
  }));
}

function LabelNode({ node }: { node: NodeApi<TreeNode> }) {
  return (
    <div className="flex items-center gap-1.5 w-full min-w-0">
      <span className="text-gray-400 flex-shrink-0 text-sm">📁</span>
      <span className="text-[11px] font-semibold text-gray-400 uppercase tracking-wider truncate">
        {node.data.name}
      </span>
    </div>
  );
}

function IssueNode({
  node,
  isLoading,
  isSelected,
}: {
  node: NodeApi<TreeNode>;
  isLoading: boolean;
  isSelected: boolean;
}) {
  return (
    <div className="flex items-center gap-1.5 w-full min-w-0">
      <span className="text-gray-400 flex-shrink-0 text-sm">📂</span>
      <span
        className={`text-[13px] truncate flex-1 ${
          isSelected ? 'text-gray-900 font-semibold' : 'text-gray-700'
        }`}
      >
        {node.data.name}
      </span>
      {isLoading && (
        <span className="flex-shrink-0 w-3 h-3 border border-gray-400 border-t-transparent rounded-full animate-spin mr-1" />
      )}
    </div>
  );
}

function CommentNode({
  node,
  isSelected,
}: {
  node: NodeApi<TreeNode>;
  isSelected: boolean;
}) {
  const comment = node.data.comment!;
  return (
    <div className={`flex items-center gap-1.5 w-full min-w-0 pl-1 ${isSelected ? 'bg-[#e8e8e8]' : ''}`}>
      <span className="text-gray-300 flex-shrink-0 text-[10px]">📄</span>
      <span
        className={`text-[12px] truncate flex-1 ${
          isSelected ? 'text-gray-900 font-medium' : 'text-gray-600'
        }`}
      >
        {node.data.name}
      </span>
      <span className="text-[10px] text-gray-400 flex-shrink-0 pr-1">
        {formatTwitterTime(comment.updated_at || comment.created_at)}
      </span>
    </div>
  );
}

interface NoteTreeProps {
  onDeleteComment?: (comment: Comment) => void;
}

function NoteTree({ onDeleteComment }: NoteTreeProps) {
  const dispatch = useDispatch<AppDispatch>();
  const issues = useSelector((state: RootState) => state.contentData.issues);
  const comments = useSelector(
    (state: RootState) => state.contentData.comments,
  );
  const selectedIssue = useSelector(
    (state: RootState) => state.contentData.selectedIssue,
  );
  const selectedComment = useSelector(
    (state: RootState) => state.contentData.selectedComment,
  );
  const userInfo = useSelector((state: RootState) => state.userData.userInfo);
  const selectedRepository = useSelector(
    (state: RootState) => state.contentData.selectedRepository,
  );

  const [issueComments, setIssueComments] = useState<
    Record<string, Comment[]>
  >({});
  const [loadingIssues, setLoadingIssues] = useState<Set<string>>(new Set());
  const containerRef = useRef<HTMLDivElement>(null);
  const [containerHeight, setContainerHeight] = useState(400);
  const treeRef = useRef<any>(null);

  // Track container height for virtual scroll
  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;
    const observer = new ResizeObserver((entries) => {
      for (const entry of entries) {
        setContainerHeight(entry.contentRect.height);
      }
    });
    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  // Sync Redux comments → issueComments when selectedIssue changes
  useEffect(() => {
    if (selectedIssue && comments.length > 0) {
      setIssueComments((prev) => ({
        ...prev,
        [selectedIssue.id]: comments,
      }));
    }
  }, [selectedIssue?.id, comments]);

  // Auto-open selected issue node in tree
  useEffect(() => {
    if (selectedIssue && treeRef.current) {
      treeRef.current.open(`issue:${selectedIssue.id}`);
    }
  }, [selectedIssue?.id]);

  const loadIssueComments = useCallback(
    async (issue: Issue) => {
      if (!userInfo || !selectedRepository) return;
      if (issueComments[issue.id] !== undefined) return;
      if (loadingIssues.has(issue.id)) return;

      setLoadingIssues((prev) => new Set([...prev, issue.id]));
      try {
        const rows = await db.getCommentsByIssue(
          userInfo.id,
          selectedRepository.id,
          issue.id,
        );
        setIssueComments((prev) => ({ ...prev, [issue.id]: rows }));
      } finally {
        setLoadingIssues((prev) => {
          const s = new Set(prev);
          s.delete(issue.id);
          return s;
        });
      }
    },
    [userInfo, selectedRepository, issueComments, loadingIssues],
  );

  const treeData = useMemo(
    () => buildTree(issues, issueComments),
    [issues, issueComments],
  );

  const handleToggle = useCallback(
    (id: string) => {
      const issueId = id.startsWith('issue:') ? id.slice(6) : null;
      if (!issueId) return;
      const issue = issues.find((i: Issue) => i.id === issueId);
      if (issue) loadIssueComments(issue);
    },
    [issues, loadIssueComments],
  );

  return (
    <div ref={containerRef} className="flex-1 overflow-hidden">
      <Tree
        ref={treeRef}
        data={treeData}
        onToggle={handleToggle}
        rowHeight={28}
        indent={12}
        width="100%"
        height={containerHeight}
        disableDrag
        disableDrop
        disableEdit
      >
        {({ node, style, dragHandle }) => {
          const { data } = node;
          const isCommentSelected =
            data.type === 'comment' &&
            !!data.comment &&
            !!selectedComment &&
            (data.comment.id === selectedComment.id ||
              (!!data.comment.uuid &&
                data.comment.uuid === selectedComment.uuid));
          const isIssueSelected =
            data.type === 'issue' && data.issue?.id === selectedIssue?.id;

          return (
            <div
              ref={dragHandle}
              style={style}
              className={`flex items-center px-2 cursor-pointer rounded-md mx-1 transition-colors duration-100 ${
                isCommentSelected ? 'bg-[#e8e8e8]' : 'hover:bg-gray-100'
              }`}
              onClick={() => {
                const d = node.data;
                if (d.type === 'issue' && d.issue) {
                  dispatch(updateSelectedIssue(d.issue));
                  dispatch(updateSelectedComment(null));
                  dispatch(updateComments([]));
                  loadIssueComments(d.issue);
                } else if (d.type === 'comment' && d.comment) {
                  dispatch(updateSelectedComment(d.comment));
                }
                if (node.isInternal) node.toggle();
              }}
              onContextMenu={() => {
                if (data.type === 'comment' && data.comment && onDeleteComment) {
                  onDeleteComment(data.comment);
                }
              }}
            >
              {data.type === 'label' && <LabelNode node={node} />}
              {data.type === 'issue' && (
                <IssueNode
                  node={node}
                  isLoading={
                    data.issue ? loadingIssues.has(data.issue.id) : false
                  }
                  isSelected={!!isIssueSelected}
                />
              )}
              {data.type === 'comment' && (
                <CommentNode node={node} isSelected={!!isCommentSelected} />
              )}
            </div>
          );
        }}
      </Tree>
    </div>
  );
}

export default NoteTree;
