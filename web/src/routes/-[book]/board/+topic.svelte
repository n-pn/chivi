<script context="module">
  export async function load({ stuff }) {
    return { props: stuff }
  }
</script>

<script>
  import DtopicForm from '$parts/Dtopic/Form.svelte'
</script>

<DtopicForm />
