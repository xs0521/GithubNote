import React from 'react';
import { PlaceholderLine, Placeholder } from 'semantic-ui-react';

interface PlaceholderAnimationLineProps {
  style?: React.CSSProperties;
}

function PlaceholderAnimationLine({ style }: PlaceholderAnimationLineProps) {
  return (
    <div className="w-full h-full flex justify-center items-center">
      <Placeholder
        style={{
          width: '100%',
          ...style,
        }}
      >
        <PlaceholderLine />
        <PlaceholderLine />
        <PlaceholderLine />
        <PlaceholderLine />
        <PlaceholderLine />
      </Placeholder>
    </div>
  );
}

export default PlaceholderAnimationLine;
