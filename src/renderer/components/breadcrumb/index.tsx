import {
  BreadcrumbSection,
  BreadcrumbDivider,
  Breadcrumb,
} from 'semantic-ui-react';

import { useSelector } from 'react-redux';
import { RootState } from '@redux/index';
import { getCommentTitle } from '@util/index';

const BreadcrumbExample: React.FC = () => {
  const selectedIssue = useSelector(
    (state: RootState) => state.contentData.selectedIssue,
  );

  const selectedRepository = useSelector(
    (state: RootState) => state.contentData.selectedRepository,
  );

  const selectedComment = useSelector(
    (state: RootState) => state.contentData.selectedComment,
  );

  return (
    <Breadcrumb size="small">
      {selectedRepository && (
        <BreadcrumbSection style={{ color: '5B636D' }}>
          {selectedRepository?.name}
        </BreadcrumbSection>
      )}
      {selectedIssue && (
        <>
          <BreadcrumbDivider />
          <BreadcrumbSection style={{ color: '#5B636D' }}>
            {selectedIssue?.title}
          </BreadcrumbSection>
        </>
      )}
      {selectedComment && (
        <>
          <BreadcrumbDivider />
          <BreadcrumbSection style={{ color: '#5B636D' }}>
            {getCommentTitle(selectedComment?.body ?? '')}
          </BreadcrumbSection>
        </>
      )}
    </Breadcrumb>
  );
};

export default BreadcrumbExample;
