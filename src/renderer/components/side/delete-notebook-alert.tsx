import React from 'react';

function DeleteNotebookAlert(
  open: boolean,
  errorMessage: string,
  onCancel: (onCancel: boolean) => void,
  onConfirm: (onConfirm: boolean) => void,
) {
  if (!open) {
    return null;
  }

  return (
    <div className="fixed inset-0 z-50">
      <button
        type="button"
        className="absolute inset-0 bg-black/30"
        aria-label="Close delete notebook confirmation"
        onClick={(e) => {
          e.preventDefault();
          e.stopPropagation();
          onCancel(false);
        }}
      />
      <div className="relative z-10 flex h-full w-full items-center justify-center">
        <div className="w-[360px] bg-white rounded-xl shadow-2xl border border-gray-200 p-4">
          <div className="text-xs font-semibold text-gray-500 mb-2">
            DELETE NOTEBOOK
          </div>
          <div className="text-sm text-gray-700">
            Are you sure you want to delete this notebook?
          </div>
          {errorMessage && (
            <div className="mt-2 text-xs text-red-500">{errorMessage}</div>
          )}
          <div className="flex items-center justify-end gap-2 mt-4">
            <button
              onClick={(e) => {
                e.preventDefault();
                e.stopPropagation();
                onCancel(false);
              }}
              className="px-2.5 py-1.5 text-xs text-gray-500 hover:text-gray-700"
            >
              Cancel
            </button>
            <button
              onClick={() => {
                onConfirm(true);
              }}
              className="px-3 py-1.5 text-xs text-white bg-gray-900 rounded-md hover:bg-gray-800"
            >
              Delete
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default DeleteNotebookAlert;
