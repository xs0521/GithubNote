import React from 'react';
import { SnackbarContent } from 'notistack';
import { Icon } from 'semantic-ui-react';

export enum BottomToastBarVariant {
  SUCCESS = 'success',
  ERROR = 'error',
  WARNING = 'warning',
  INFO = 'info',
}

interface BottomToastBarProps {
  id: string | number;
  message: string | React.ReactNode;
  variant: BottomToastBarVariant;
  description?: string;
}

const getIcon = (variant: BottomToastBarVariant): React.ReactNode => {
  switch (variant) {
    case BottomToastBarVariant.SUCCESS:
      return <Icon name="check circle" color="green" size="large" />;
    case BottomToastBarVariant.ERROR:
      return <Icon name="x" color="red" size="big" />;
    case BottomToastBarVariant.WARNING:
      return <Icon name="warning sign" color="yellow" size="large" />;
    case BottomToastBarVariant.INFO:
      return <Icon name="info circle" color="blue" size="large" />;
    default:
      return <Icon name="question circle" color="black" size="large" />;
  }
};

const BottomToastBar = React.forwardRef<HTMLDivElement, BottomToastBarProps>(
  (props, ref) => {
    const { id, message, variant, description } = props;

    return (
      <SnackbarContent
        ref={ref}
        role="alert"
        style={{ backgroundColor: 'transparent' }}
      >
        <div className="flex items-start justify-between w-[300px] bg-[#FDFDFD] rounded-lg shadow-lg p-5 border-[#DCDCDC]/[0.5] border-[1px]">
          {getIcon(variant)}
          <div className="flex flex-col h-full w-full ml-4 mt-[-4px]">
            <div className="text-lg text-[#292929] font-medium">{message}</div>
            {description && (
              <div className="text-base text-[#525252] font-normal mt-2">
                {description}
              </div>
            )}
          </div>
        </div>
      </SnackbarContent>
    );
  },
);

export default BottomToastBar;
