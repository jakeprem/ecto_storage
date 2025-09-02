defmodule EctoStorage.Schema do
  import Ecto.Schema, only: [has_one: 2]

  defmacro has_one_attached(field, _opts \\ []) do
    ledger_field = :"#{field}_ledger"
    ledger_field_id = :"#{field}_ledger_id"

    quote do
      belongs_to unquote(ledger_field), EctoStorage.Attachments.Ledger

      has_one unquote(field), EctoStorage.Attachments.Attachment,
        foreign_key: :ledger_id,
        references: unquote(ledger_field_id)

      has_one :"#{unquote(field)}_blob", through: [unquote(field), :blob]
    end
  end
end
