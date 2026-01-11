import { useState } from 'react';
import { Input, Confirm } from 'semantic-ui-react';

const InputComponent = (
  placeholder: string,
  value: string,
  onChange: (value: string) => void,
) => {
  return (
    <Input
      className="custom-input"
      placeholder={placeholder}
      defaultValue={value}
    />
  );
};

const ConfirmComponent = (
  placeholder: string,
  open: boolean,
  onCancel: (onCancel: boolean) => void,
  onConfirm: (onConfirm: boolean, text: string) => void,
) => {
  const [inputValue, setInputValue] = useState('');

  return (
    <Confirm
      header="Rename"
      content={InputComponent(placeholder, inputValue, setInputValue)}
      confirmButton="Confirm"
      cancelButton="Cancel"
      open={open}
      onCancel={(e) => {
        e.preventDefault();
        e.stopPropagation();
        onCancel(false);
      }}
      onConfirm={() => {
        onConfirm(true, inputValue);
      }}
    />
  );
};

export default ConfirmComponent;
