<script context="module">
  import { page } from '$app/stores'
</script>

<script>
  import DtopicForm from '$parts/Dtopic/Form.svelte'

  $: dboard = $page.stuff.dboard
</script>

<DtopicForm {dboard} />
